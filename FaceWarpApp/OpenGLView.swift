//
//  OpenGLView.swift
//  iOSSwiftOpenGL
//
//  Created by Bradley Griffith on 6/29/14.
//  Copyright (c) 2014 Bradley Griffith. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import OpenGLES
import GLKit
import CoreVideo
import CoreGraphics
import CoreFoundation
import AVFoundation

import ImageIO

typealias ImagePosition = (GLfloat, GLfloat, GLfloat)
typealias TexturePosition = (GLfloat, GLfloat)
//typealias Color = (CFloat, CFloat)
//var a : CGFloat = 0
//var b : CFloat = a


struct Coordinate {
    var xyz : ImagePosition
    var uv : TexturePosition
    var alpha : GLfloat
}


var leye_dlib = [36, 37, 38, 39, 40, 41];
var reye_dlib = [42, 43, 44, 45, 46, 47];

var outlinePoints : [Float] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26];

var FaceIndicesSmall : [GLubyte] = [
    1, 2, 0,
    0, 2, 3,
]




func time<O>(name: String, f : ()->O )-> O {
    let startTime = NSDate()
    let rez = f()
    let deltaT = NSDate().timeIntervalSinceDate(startTime)
    print("\(name) took \(deltaT)")
    return rez
}




class OpenGLView: UIView {
    @IBOutlet weak var uiContainer: UIView!

    var eaglLayer: CAEAGLLayer!
    var context: EAGLContext!
    
    var captureManager : CaptureManager?
    var renderer : Renderer?
    
    var camera : Int = 1
    
    /* Class Methods
    ------------------------------------------*/
    
    override class func layerClass() -> AnyClass {
        // In order for our view to display OpenGL content, we need to set it's
        //   default layer to be a CAEAGLayer
        return CAEAGLLayer.self
    }
    
    
    /* Lifecycle
    ------------------------------------------*/
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate.view = self
        
        self.setupLayer()
        self.setupContext()
        
        self.renderer = Renderer(withContext: context, andLayer: eaglLayer, andCamera: camera)
        setupPipelineWithCamera(camera, andRenderer: renderer!)
        
        
    }
    
    /* Gesture recogniser
    ------------------------------------------*/
    
    func singleTap(rec : UITapGestureRecognizer) {
        self.renderer!.doFaceBlur = !(self.renderer!.doFaceBlur)
        self.renderer!.scheduleSave()
    }
    
    /* Instance Methods
    ------------------------------------------*/
    
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
//        self.renderer = nil
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
    
    func setupLayer() {
        // CALayer's are, by default, non-opaque, which is 'bad for performance with OpenGL',
        //   so let's set our CAEAGLLayer layer to be opaque.
        self.eaglLayer	= self.layer as! CAEAGLLayer
        self.eaglLayer.opaque = true
        self.contentScaleFactor = UIScreen.mainScreen().scale
        self.eaglLayer.contentsScale = UIScreen.mainScreen().scale
        if #available(iOS 8.0, *) {
            self.eaglLayer.bounds.size.width = UIScreen.mainScreen().fixedCoordinateSpace.bounds.width
            self.eaglLayer.bounds.size.height = UIScreen.mainScreen().fixedCoordinateSpace.bounds.height
        } else {
            self.eaglLayer.bounds.size.width = UIScreen.mainScreen().bounds.width
            self.eaglLayer.bounds.size.height = UIScreen.mainScreen().bounds.height
        }
        
    }
    
    func setupContext() {
        // Just like with CoreGraphics, in order to do much with OpenGL, we need a context.
        //   Here we create a new context with the version of the rendering API we want and
        //   tells OpenGL that when we draw, we want to do so within this context.
        let api: EAGLRenderingAPI = EAGLRenderingAPI.OpenGLES2
        self.context = EAGLContext(API: api)
        
        if (self.context == nil) {
            print("Failed to initialize OpenGLES 3.0 context!")
            exit(1)
        }
        
        if (!EAGLContext.setCurrentContext(self.context)) {
            print("Failed to set current OpenGL context!")
            exit(1)
        }
    }
}
///////////////////////////////////////

