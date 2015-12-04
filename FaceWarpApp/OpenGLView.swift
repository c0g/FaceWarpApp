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
import Photos

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




class OpenGLView: UIImageView
{
    @IBOutlet weak var uiContainer: UIView!

    var eaglLayer: CAEAGLLayer!
    var context: EAGLContext!
    
    var captureManager : CaptureManager?
    var renderer : Renderer?
    
    var camera : Int = 1
    
    
    /* Lifecycle
    ------------------------------------------*/
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.image = UIImage(named: "img.jpg")!
        contentMode = .ScaleAspectFit
    }
}
///////////////////////////////////////

