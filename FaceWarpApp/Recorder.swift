//
//  Recorder.swift
//  FaceWarpApp
//
//  Created by Thomas Nickson on 11/10/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

import Foundation
import CoreVideo
import CoreMedia
import AVFoundation
import AssetsLibrary
import Photos

enum RecorderState {
    case Idle, Preparing, Recording, Writing, Error
}

class Recorder {
    
    let audioQueue = dispatch_queue_create("com.PHI.AudioQueue", nil)
    let videoQueue = dispatch_queue_create("com.PHI.VideoQueue", nil)
    let writeQueue = dispatch_queue_create("com.PHI.WriteQueue", nil)
    
    var needTime : Bool = true
    
    var state : RecorderState  = .Idle
    var assetWriter : AVAssetWriter? = nil
    var awAudio : AVAssetWriterInput? = nil
    var awVideo : AVAssetWriterInput? = nil
    
    var assetWriterPixelBufferInput : AVAssetWriterInputPixelBufferAdaptor? = nil
    var vidURL : NSURL?
    
    func prepareRecord(forWidth width : Int, andHeight height : Int) {
        state = .Preparing
        print("Preparing")
        let dir =  NSTemporaryDirectory()
        vidURL = NSURL(fileURLWithPath: "\(dir)/movie.mov")
        do {
            try NSFileManager.defaultManager().removeItemAtURL(vidURL!)
        } catch {
            print("Delete movie.mov failed")
        }
        do {
            assetWriter = try AVAssetWriter(URL: vidURL!, fileType: AVFileTypeAppleM4V)
            needTime = true
            initAudio()
            initVideo(withWidth: width, andHeight: height)
            initWriter()
        } catch _ {
            print("Assert writer didn't init")
            state = .Error
        }
        
    }
    
    func initAudio() {
        var audioSettings = [String: AnyObject]()
        audioSettings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC)
        audioSettings[AVNumberOfChannelsKey] =  1
        audioSettings[AVSampleRateKey] = AVAudioSession.sharedInstance().sampleRate
        audioSettings[AVEncoderBitRateKey] = 64000
        awAudio = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: audioSettings)
        awAudio!.expectsMediaDataInRealTime = true
    }
    
    func initVideo(withWidth width : Int, andHeight height : Int) {
        let videoSettings = [ AVVideoCodecKey: AVVideoCodecH264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height ]
        awVideo = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoSettings as! [String : AnyObject])
        awVideo?.expectsMediaDataInRealTime = true
        
        var sourcePixelBufferAttributes = [String: AnyObject]()
        sourcePixelBufferAttributes[ kCVPixelBufferPixelFormatTypeKey as String ] = Int(kCVPixelFormatType_32BGRA)
        sourcePixelBufferAttributes[ kCVPixelBufferWidthKey as String ] = width
        sourcePixelBufferAttributes[ kCVPixelBufferHeightKey as String ] = height
        
        assetWriterPixelBufferInput = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: awVideo!, sourcePixelBufferAttributes: sourcePixelBufferAttributes)
    }
    
    func initWriter() {
        if let awVideo = awVideo, let awAudio = awAudio {
            assetWriter!.addInput(awAudio)
            assetWriter!.addInput(awVideo)
            if assetWriter!.startWriting() {
                state = .Recording
            }
            switch assetWriter!.status {
            case .Cancelled: print("cancelled")
            case .Completed: print("Completed")
            case .Failed: print("failed")
            case .Unknown: print("unknown")
            case .Writing: print("writing")
            }
            while assetWriter!.status != .Writing {
                switch assetWriter!.status {
                case .Cancelled: print("cancelled")
                case .Completed: print("Completed")
                case .Failed: print(assetWriter!.error)
                case .Unknown: print("unknown")
                case .Writing: print("writing")
                }
            }
            
        }
    }
    
    func stopRecordingAndSave() {
        print("Stopping")
        state = .Writing
        awVideo!.markAsFinished()
        awAudio!.markAsFinished()
        dispatch_async(writeQueue, {
            self.assetWriter!.finishWritingWithCompletionHandler {
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(self.vidURL!)
                    }, completionHandler: {
                        (success : Bool, error : NSError?) -> Void in
                        if let error = error {
//                            let mailURL = "mailto:tom.nickson@gmail.com?subject=\"error\"&body=\(error)"
//                            let url = mailURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
//                            UIApplication.sharedApplication().openURL(NSURL(string: url!)!)

                        }
                })
            }
        })
    }
    
    func setTime(time : CMTime) {
        if needTime {
            needTime = false
            assetWriter?.startSessionAtSourceTime(time)
        }
    }
    
    func addVideoFrame(frame : CVPixelBufferRef, atTime time: CMTime){
        setTime(time)
        if state == .Recording {
            dispatch_async(videoQueue!, {
                if let awVideo = self.awVideo {
                    if awVideo.readyForMoreMediaData {
                        if let awpbi = self.assetWriterPixelBufferInput {
                            awpbi.appendPixelBuffer(frame, withPresentationTime: time)
                        }
                    }
                }
            })
        }
    }
    
    func addAudioSampleBuffer(sampleBuffer : CMSampleBufferRef) {
        setTime(CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
        if state == .Recording {
            dispatch_async(audioQueue, {
                if let awAudio = self.awAudio {
                    if awAudio.readyForMoreMediaData {
                        awAudio.appendSampleBuffer(sampleBuffer)
                    }
                }
            })
        }
    }
}