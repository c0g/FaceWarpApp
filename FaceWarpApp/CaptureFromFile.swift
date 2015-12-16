//
//  CaptureFromFile.swift
//  FaceWarpApp
//
//  Created by Thomas Nickson on 15/12/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

import Foundation
import AVFoundation
class CaptureFromFile {
    weak var renderer : Renderer?
    var reader : AVAssetReader?
    init(withRenderer r : Renderer) {
        renderer = r
        loadUp()
    }
//
//            - (void) readMovie:(NSURL *)url
//        {
//            AVURLAsset * asset = [AVURLAsset URLAssetWithURL:url options:nil];
//            [asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler:
//                ^{
//                dispatch_async(dispatch_get_main_queue(),
//                ^{
//                AVAssetTrack * videoTrack = nil;
//                NSArray * tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
//                if ([tracks count] == 1)
//                {
//                videoTrack = [tracks objectAtIndex:0];
//                
//                NSError * error = nil;
//                
//                // _movieReader is a member variable
//                _movieReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
//                if (error)
//                NSLog(error.localizedDescription);
//                
//                NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
//                NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
//                NSDictionary* videoSettings =
//                [NSDictionary dictionaryWithObject:value forKey:key];
//                
//                [_movieReader addOutput:[AVAssetReaderTrackOutput 
//                assetReaderTrackOutputWithTrack:videoTrack 
//                outputSettings:videoSettings]];
//                [_movieReader startReading];
//                }
//                });
//                }];
//        }
    func loadUp() {
//        let path = NSHomeDirectory() + "/movie.mov"
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"SomeFile" ofType:@"jpeg"]
        let path = NSBundle.mainBundle().pathForResource("movie", ofType: "mov")!
        let asset = AVURLAsset(URL: NSURL.fileURLWithPath(path))
        print(asset)
        print(asset.tracksWithMediaType(AVMediaTypeVideo))
        let videoTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0]
        self.reader = try! AVAssetReader(asset: asset)
        let videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_32BGRA)]
        self.reader!.addOutput(AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoSettings))
        self.reader!.startReading()
        renderer!.addReader(reader!)
    }
//    - (void) readNextMovieFrame
//    {
//    if (_movieReader.status == AVAssetReaderStatusReading)
//    {
//    AVAssetReaderTrackOutput * output = [_movieReader.outputs objectAtIndex:0];
//    CMSampleBufferRef sampleBuffer = [output copyNextSampleBuffer];
//    if (sampleBuffer)
//    {
//    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//    
//    // Lock the image buffer
//    CVPixelBufferLockBaseAddress(imageBuffer,0);
//    
//    // Get information of the image
//    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
//    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
//    size_t width = CVPixelBufferGetWidth(imageBuffer);
//    size_t height = CVPixelBufferGetHeight(imageBuffer);
//    
//    //
//    //  Here's where you can process the buffer!
//    //  (your code goes here)
//    //
//    //  Finish processing the buffer!
//    //
//    
//    // Unlock the image buffer
//    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
//    CFRelease(sampleBuffer);
//    }
//    }
//    }
//    func readAFuckingFrame() {
//        if reader?.status == AVAssetReaderStatus.Reading {
//            let output = reader!.outputs[0]
//            let sampleBuffer = output.copyNextSampleBuffer()
//            print(sampleBuffer)
//            renderer.getFromSampleBuffer(sampleBuffer!)
//        } else {
//            print("Fucked")
//        }
//
//        let a = 1+1
//    }
    
}