//
//  LiveOGLView.swift
//  FaceWarpApp
//
//  Created by Thomas Nickson on 01/11/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

import Foundation
import AVFoundation

class LiveOGLView : OpenGLView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate.view = self
        self.renderer = Renderer(withContext: context, andLayer: eaglLayer, andCamera: camera)
        setupPipelineWithCamera(camera, andRenderer: renderer!)
    }
    
    func setupPipelineWithCamera(camera : Int, andRenderer renderer : Renderer) {
        if CaptureManager.devices().count > 0 { // check if we're running in the sim to debug ui shit
            let device = CaptureManager.devices()[camera]
            for format in device.formats as! [AVCaptureDeviceFormat] {
                if CMVideoFormatDescriptionGetDimensions(format.formatDescription).height == 960 {
                    do {
                        try device.lockForConfiguration()
                        device.activeFormat = format
                        device.unlockForConfiguration()
                    } catch {
                        print("Could not set config")
                    }
                }
            }
            
            self.captureManager = CaptureManager(withDevice: device)
            renderer.camera = camera
            
            do {
                try self.captureManager?.connectToRenderer(renderer)
            } catch {
                print("Capture manager could not connect to renderer")
                exit(1)
            }
            
            self.captureManager?.start()
        }
    }
    
    func toggleCamera() {
        self.captureManager!.stop()
        self.captureManager = nil
        
        if self.camera == 0{
            camera = 1
        } else {
            camera = 0
        }
        //
        self.setupPipelineWithCamera(camera, andRenderer: renderer!)
    }
    
    @IBOutlet weak var overlayImage: UIImageView!
    @IBOutlet weak var instructions: UILabel!
    func hideInstructions(hidden : Bool) {
        instructions.hidden = hidden
        uiContainer.hidden = !hidden
        switch UIApplication.sharedApplication().statusBarOrientation {
        case .Portrait:
            overlayImage.hidden = hidden
            instructions.text = "Face the screen\nwith a neutral expression\nand hold for 3 seconds"
        case _:
            overlayImage.hidden = true
            instructions.text = "Rotate the device\nto portrait\nand try again"
        }
        
    }
    
    func setTextForCount(count : Int) {
        instructions.text = "Face the screen\nwith a neutral expression\nand hold for \(count) seconds"
    }
}