//
//  CaptureManager.swift
//  FaceWarpApp
//
//  Created by Thomas Nickson on 01/10/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

import Foundation
import AVFoundation

enum CaptureError : ErrorType {
    case CONNECTION_FAILURE
}

class CaptureManager {
    
    let session : AVCaptureSession
    
    static func devices() -> [AVCaptureDevice]{
        return  AVCaptureDevice.devices() as! [AVCaptureDevice]
    }
    
    init?(withDevice device: AVCaptureDevice) {
        session = AVCaptureSession()
        
        // Attempt to attach the device to our session
        var input : AVCaptureDeviceInput? = nil
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch {
            print("Failed to connect device \(device.description)")
            return nil
        }
        session.beginConfiguration()
        session.addInput(input!)
        session.commitConfiguration()
    }
    
    func connectToRenderer(renderer: Renderer) throws {
        // Attempt to initiate an output, tied to the sample buffer delegate (renderer)
        var output : AVCaptureVideoDataOutput? = nil
        output = AVCaptureVideoDataOutput()
        guard let _ = output else {
            print("Failed to get video output")
            throw CaptureError.CONNECTION_FAILURE
        }
        output?.alwaysDiscardsLateVideoFrames = true // Stops things getting bogged down if the CPU is being hammered
        output?.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),] // 32BGRA needed to be OpenGL compatible
        output?.setSampleBufferDelegate(renderer, queue: dispatch_get_main_queue()) // run on main thread
        session.beginConfiguration()
        session.addOutput(output)
        session.sessionPreset = AVCaptureSessionPreset640x480
        session.commitConfiguration()
    }
    
    func start() {
        session.startRunning()
    }
    
    func stop() {
        session.stopRunning()
    }
    
}