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
    
    var eaglLayer: CAEAGLLayer!
    var context: EAGLContext!
    
    var captureManager : CaptureManager?
    var renderer : Renderer?
    
    
    
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
        self.setupLayer()
        self.setupContext()
        
        let device = CaptureManager.devices()[1]
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
        self.renderer = Renderer(withContext: context, andLayer: eaglLayer)
        
        do {
            try self.captureManager?.connectToRenderer(self.renderer!)
        } catch {
            print("Capture manager could not connect to renderer")
            exit(1)
        }
        
        self.captureManager?.start()
    }
    
    /* Gesture recogniser
    ------------------------------------------*/
    
    func singleTap(rec : UITapGestureRecognizer) {
        self.renderer!.doFaceBlur = !(self.renderer!.doFaceBlur)
        self.renderer!.scheduleSave()
    }
    
    /* Instance Methods
    ------------------------------------------*/
    
    func setupLayer() {
        // CALayer's are, by default, non-opaque, which is 'bad for performance with OpenGL',
        //   so let's set our CAEAGLLayer layer to be opaque.
        self.eaglLayer	= self.layer as! CAEAGLLayer
        self.eaglLayer.opaque = true
        self.contentScaleFactor = UIScreen.mainScreen().scale
        self.eaglLayer.contentsScale = UIScreen.mainScreen().scale
        self.eaglLayer.bounds.size.width = UIScreen.mainScreen().fixedCoordinateSpace.bounds.width
        self.eaglLayer.bounds.size.height = UIScreen.mainScreen().fixedCoordinateSpace.bounds.height
    }
    
    func setupContext() {
        // Just like with CoreGraphics, in order to do much with OpenGL, we need a context.
        //   Here we create a new context with the version of the rendering API we want and
        //   tells OpenGL that when we draw, we want to do so within this context.
        let api: EAGLRenderingAPI = EAGLRenderingAPI.OpenGLES3
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

