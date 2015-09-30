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
}


var leye_dlib = [36, 37, 38, 39, 40, 41];
var reye_dlib = [42, 43, 44, 45, 46, 47];

var outlinePoints : [Float] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26];

var FaceIndicesSmall : [GLubyte] = [
    1, 2, 0,
    0, 2, 3,
]

var FaceIndices : [GLushort] = [ 0, 36, 17,36, 18, 17,36, 37, 18,37, 19, 18,37, 38, 19,38, 20, 19,38, 39, 20,39, 21, 20,36, 41, 37,41, 40, 37,40, 38, 37,40, 39, 38,39, 27, 21,27, 22, 21,27, 42, 22,42, 23, 22,42, 43, 23,43, 24, 23,43, 44, 24,44, 25, 24,44, 45, 25,45, 26, 25,45, 16, 26,42, 47, 43,47, 44, 43,47, 46, 44,46, 45, 44,39, 28, 27,28, 42, 27,32, 33, 30,33, 34, 30,31, 30, 32,31, 30, 29,34, 35, 30,35, 29, 30,35, 28, 29,31, 29, 28, 0,  1, 36,39, 31, 28,35, 42, 28,15, 16, 45,40, 31, 39,35, 47, 42, 1, 41, 36, 1, 40, 41,15, 45, 46,15, 46, 47,35, 15, 47, 1, 31, 40, 1,  2, 31,35, 14, 15, 2, 48, 31, 3, 48,  2, 4, 48,  3,54, 14, 35,54, 13, 14,12, 13, 54, 4,  5, 48, 5, 59, 48,11, 12, 54,55, 11, 54,10, 11, 55,56, 10, 55, 9, 10, 56, 5,  6, 59, 6, 58, 59, 6,  7, 58, 7, 57, 58, 7,  8, 57,57,  9, 56, 8,  9, 57,48, 49, 31,53, 54, 35,49, 50, 31,52, 53, 35,50, 32, 31,52, 35, 34,50, 51, 32,51, 52, 34,51, 34, 33,51, 33, 32,48, 60, 49,59, 60, 48,60, 67, 61,64, 54, 53,55, 54, 64,65, 64, 63,67, 62, 61,65, 63, 62,67, 66, 62,66, 65, 62,51, 52, 63,61, 62, 51,60, 61, 49,61, 50, 49,63, 64, 53,63, 53, 52,61, 51, 50,51, 62, 63,59, 67, 60,59, 58, 67,58, 57, 67,57, 66, 67,57, 65, 66,57, 56, 65,65, 55, 56,55, 64, 65]

var Vertices = [
    Coordinate(xyz : (-1, -1, 0), uv : (0, 1)),
    Coordinate(xyz : (-1,  1, 0), uv : (0, 0)),
    Coordinate(xyz : ( 1,  1, 0), uv : (1, 0)),
    Coordinate(xyz : ( 1, -1, 0), uv : (1, 1)),
]

var Indices: [GLubyte] = [
    1, 2, 0,
    0, 2, 3,
]

extension Array {
    func size () -> Int {
        if self.count > 0 {
            return self.count * sizeofValue(self[0])
        } else {
            return 0
        }
    }
}

extension Int32 {
    func __conversion() -> GLenum {
        return GLuint(self)
    }
    
    func __conversion() -> GLboolean {
        return GLboolean(UInt8(self))
    }
}

extension Int {
    func __conversion() -> Int32 {
        return Int32(self)
    }
    
    func __conversion() -> GLubyte {
        return GLubyte(self)
    }
    
}

func time<O>(name: String, f : ()->O )-> O {
    let startTime = NSDate()
    let rez = f()
    let deltaT = NSDate().timeIntervalSinceDate(startTime)
    print("\(name) took \(deltaT)")
    return rez
}

func makeEdges(n: Int, scalex: CGFloat, scaley: CGFloat) -> [PhiPoint] {
    var points : [PhiPoint] = []
    for x in 0...n {
        points.append(PhiPoint(x: Int32(round(scalex * CGFloat(x) / CGFloat(n))), y: Int32(round(scaley * 0))))
        points.append(PhiPoint(x: Int32(round(scalex * CGFloat(x) / CGFloat(n))), y: Int32(round(scaley * 1))))
    }
    for y in 1..<n {
        points.append(PhiPoint(x: Int32(round(scalex * 0)), y: Int32(round(scaley * CGFloat(y) / CGFloat(n)))))
        points.append(PhiPoint(x: Int32(round(scalex * 1)), y: Int32(round(scaley * CGFloat(y) / CGFloat(n)))))
    }
    return points
}


class OpenGLView: UIView, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var written = false
    var numfaces = 0
    let faceFinder : FaceFinder = FaceFinder()
    let warper : Warper = Warper()
    
    var frameCounter : Int = 0
    
    var eaglLayer: CAEAGLLayer!
    var context: EAGLContext!
    var colorRenderBuffer: GLuint = GLuint()
    var positionSlot: GLuint = GLuint()
    var uvSlot: GLuint = GLuint()
    var coordSlot : GLuint = GLuint()
    var coordBuffer : GLuint = GLuint()
    
    var indexBuffer: GLuint = GLuint()
    var positionBuffer: GLuint = GLuint()
    var uvBuffer: GLuint = GLuint()
    
    var faceIndexBuffer: GLuint = GLuint()
    var facePositionBuffer: GLuint = GLuint()
    var faceUvBuffer: GLuint = GLuint()
    
    var textureID: GLuint = GLuint()
    var textureSlot: GLint = GLint()
    var textureImage : GLKTextureInfo? = nil
    
    var outTex : CVOpenGLESTextureRef? = nil
    
    var renderPB : CVPixelBufferRef? = nil
    var renderTex : CVOpenGLESTextureRef? = nil
    var framebuffer : GLuint = GLuint()
    var renderTexName : GLuint = GLuint()
    
    var session : AVCaptureSession? = nil
    var textureCache : CVOpenGLESTextureCacheRef? = nil
    var videoTexture : CVOpenGLESTextureRef? = nil
    
    var pixelBuffer : CVImageBuffer? = nil
    
    var flipPixelBuffer : CVPixelBufferRef? = nil
    var flipTexture : CVOpenGLESTextureRef? = nil
    
    var smallPixelBuffer : CVPixelBufferRef? = nil
    var smallTexture : CVOpenGLESTextureRef? = nil
    let smallTextureScale = 4
    
    var VAO:GLuint = GLuint()
    var VFaceAO:GLuint = GLuint()
    
    var detector : CIDetector? = nil
    
    var q_high_p : dispatch_queue_t? = nil
    
    let faceLock = dispatch_queue_create("com.phi.FaceLock", nil)
    
    var edges : [PhiPoint] = []
    
    var faceVertices : [Coordinate] = []
    var currentIndices : [GLushort] = []
    var iter = 0
    
    
    
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
        self.setupDetector()
        self.setupEdges()
        self.setupQueues()

        self.setupLayer()

        self.setupContext()

        self.setupRenderBuffer()

        self.setupFrameBuffer()
        
        self.setupRenderTexture()
        self.setupFlipTexture()
        self.setupSmallTexture()

        self.compileShaders()

        self.setupTextureCache()

        self.setupVBOs()
        self.setupFaceIndices()

        self.setupAVCapture()

    }
    
    
    
    /* Instance Methods
    ------------------------------------------*/
    
    func setupQueues() {
        q_high_p = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    }
    
    func setupDetector() {
        let context = CIContext()
        let opt = [CIDetectorAccuracy : CIDetectorAccuracyLow]
        detector = CIDetector(ofType: CIDetectorTypeFace, context: context, options: opt)
    }
    
    func setupLayer() {
        // CALayer's are, by default, non-opaque, which is 'bad for performance with OpenGL',
        //   so let's set our CAEAGLLayer layer to be opaque.
        self.eaglLayer	= self.layer as! CAEAGLLayer
        self.eaglLayer.opaque = true
        self.contentScaleFactor = UIScreen.mainScreen().scale
        self.eaglLayer.contentsScale = UIScreen.mainScreen().scale
        self.eaglLayer.bounds.size.width = UIScreen.mainScreen().bounds.width
        self.eaglLayer.bounds.size.height = UIScreen.mainScreen().bounds.height
        
        // Add a fucken button
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        [button addTarget:self
//            action:@selector(aMethod:)
//        forControlEvents:UIControlEventTouchUpInside];
//        [button setTitle:@"Show View" forState:UIControlStateNormal];
//        button.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
//        [view addSubview:button];
        let button = UIButton(type: UIButtonType.RoundedRect)
        button.setTitle("Fucken button", forState: UIControlState.Normal)
        button.frame = CGRectMake(80.0, 210.0, 160.0, 40.0)
        self.addSubview(button)
    }
    
    func setupEdges() {
        edges = makeEdges(16, scalex: 1280, scaley: 720)
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
    
    func setupRenderBuffer() {
        glGenRenderbuffers(1, &self.colorRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self.colorRenderBuffer)
        self.context.renderbufferStorage(Int(GL_RENDERBUFFER), fromDrawable:self.eaglLayer)
    }
    
    func setupFrameBuffer() {
        glGenFramebuffers(1, &framebuffer);
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer);
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), self.colorRenderBuffer)
    }
    
    func setupRenderTexture() {
        let options = [
            kCVPixelBufferCGImageCompatibilityKey as String: false,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: false,
            kCVPixelFormatOpenGLESCompatibility as String: true,
            kCVPixelBufferIOSurfacePropertiesKey as String: [NSObject: NSObject]()
        ]

        let height = UIScreen.mainScreen().bounds.height * self.contentScaleFactor
        let width = UIScreen.mainScreen().bounds.width * self.contentScaleFactor
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(height), Int(width), kCVPixelFormatType_32BGRA, options, &renderPB)
        if status != kCVReturnSuccess {
            print("Pixel buffer with image failed creating CVPixelBuffer with error \(status)")
            exit(1)
        }
        guard let _ = renderPB else {
            print("Pixel buffer did not allocate")
            exit(1)
        }
        
        var texCacheRef : CVOpenGLESTextureCacheRef?
        let cacheStatus = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, self.context, nil, &texCacheRef)
        if cacheStatus != kCVReturnSuccess {
            print("Creating texture cache failed with error \(cacheStatus)")
            exit(1)
        }
        
        let res = CVOpenGLESTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            texCacheRef!,
            renderPB!,
            nil,
            GLenum(GL_TEXTURE_2D),
            GLint(GL_RGBA),
            GLsizei(height),
            GLsizei(width),
            GLenum(GL_BGRA),
            GLenum(GL_UNSIGNED_BYTE),
            0,
            &renderTex)
        guard res == kCVReturnSuccess else {
            print("Create texture from image failed with code \(res)")
            exit(1)
        }
        
        renderTexName = CVOpenGLESTextureGetName(renderTex!)
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), CVOpenGLESTextureGetName(renderTex!), 0);
    }
    
    func setupFlipTexture() {
        let options = [
            kCVPixelBufferCGImageCompatibilityKey as String: false,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: false,
            kCVPixelFormatOpenGLESCompatibility as String: true,
            kCVPixelBufferIOSurfacePropertiesKey as String: [NSObject: NSObject]()
        ]
        
        let height = 1280
        let width = 720
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(height), Int(width), kCVPixelFormatType_32BGRA, options, &flipPixelBuffer)
        if status != kCVReturnSuccess {
            print("Pixel buffer with image failed creating CVPixelBuffer with error \(status)")
            exit(1)
        }
        guard let _ = flipPixelBuffer else {
            print("Pixel buffer did not allocate")
            exit(1)
        }
        
        var texCacheRef : CVOpenGLESTextureCacheRef?
        let cacheStatus = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, self.context, nil, &texCacheRef)
        if cacheStatus != kCVReturnSuccess {
            print("Creating texture cache failed with error \(cacheStatus)")
            exit(1)
        }
        
        let res = CVOpenGLESTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            texCacheRef!,
            flipPixelBuffer!,
            nil,
            GLenum(GL_TEXTURE_2D),
            GLint(GL_RGBA),
            GLsizei(height),
            GLsizei(width),
            GLenum(GL_BGRA),
            GLenum(GL_UNSIGNED_BYTE),
            0,
            &flipTexture)
        guard res == kCVReturnSuccess else {
            print("Create texture from image failed with code \(res)")
            exit(1)
        }
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), CVOpenGLESTextureGetName(flipTexture!), 0);
    }
    
    func setupSmallTexture() {
        let options = [
            kCVPixelBufferCGImageCompatibilityKey as String: false,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: false,
            kCVPixelFormatOpenGLESCompatibility as String: true,
            kCVPixelBufferIOSurfacePropertiesKey as String: [NSObject: NSObject]()
        ]
        
        let height = 1280 / smallTextureScale
        let width = 720 / smallTextureScale
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(height), Int(width), kCVPixelFormatType_32BGRA, options, &smallPixelBuffer)
        if status != kCVReturnSuccess {
            print("Pixel buffer with image failed creating CVPixelBuffer with error \(status)")
            exit(1)
        }
        guard let _ = smallPixelBuffer else {
            print("Pixel buffer did not allocate")
            exit(1)
        }
        
        var texCacheRef : CVOpenGLESTextureCacheRef?
        let cacheStatus = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, self.context, nil, &texCacheRef)
        if cacheStatus != kCVReturnSuccess {
            print("Creating texture cache failed with error \(cacheStatus)")
            exit(1)
        }
        
        let res = CVOpenGLESTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            texCacheRef!,
            smallPixelBuffer!,
            nil,
            GLenum(GL_TEXTURE_2D),
            GLint(GL_RGBA),
            GLsizei(height),
            GLsizei(width),
            GLenum(GL_BGRA),
            GLenum(GL_UNSIGNED_BYTE),
            0,
            &smallTexture)
        guard res == kCVReturnSuccess else {
            print("Create texture from image failed with code \(res)")
            exit(1)
        }

        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), CVOpenGLESTextureGetName(smallTexture!), 0);
    }
    
    func compileShader(shaderName: String, shaderType: GLenum) -> GLuint {
        
        // Get NSString with contents of our shader file.
        let shaderPath: String! = NSBundle.mainBundle().pathForResource(shaderName, ofType: "glsl")
        var shaderString: NSString?
        do {
            shaderString = try NSString(contentsOfFile:shaderPath, encoding: NSUTF8StringEncoding)
        } catch let error as NSError {
            print(error)
            shaderString = nil
        }
        if (shaderString == nil) {
            print("Failed to set contents shader of shader file!")
        }
        
        // Tell OpenGL to create an OpenGL object to represent the shader, indicating if it's a vertex or a fragment shader.
        let shaderHandle: GLuint = glCreateShader(shaderType)
        
        if shaderHandle == 0 {
            NSLog("Couldn't create shader")
        }
        // Conver shader string to CString and call glShaderSource to give OpenGL the source for the shader.
        var shaderStringUTF8 = shaderString!.UTF8String
        var shaderStringLength: GLint = GLint(Int32(shaderString!.length))
        glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength)
        
        // Tell OpenGL to compile the shader.
        glCompileShader(shaderHandle)
        
        // But compiling can fail! If we have errors in our GLSL code, we can here and output any errors.
        var compileSuccess: GLint = GLint()
        glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &compileSuccess)
        if (compileSuccess == GL_FALSE) {
            print("Failed to compile shader \(shaderName)!")
            // TODO: Actually output the error that we can get from the glGetShaderInfoLog function.
            var infolog = [GLchar](count: 100, repeatedValue: 0)
            var length : GLsizei = GLsizei()
            glGetShaderInfoLog(shaderHandle, 100, &length, &infolog)
            print(String.fromCString(&infolog))
            exit(1);
        }
        
        return shaderHandle
    }
    
    func compileShaders() {
        
        // Compile our vertex and fragment shaders.
        let vertexShader: GLuint = self.compileShader("TextureVertex", shaderType: GLenum(GL_VERTEX_SHADER))
        let fragmentShader: GLuint = self.compileShader("TextureFragment", shaderType: GLenum(GL_FRAGMENT_SHADER))
        
        // Call glCreateProgram, glAttachShader, and glLinkProgram to link the vertex and fragment shaders into a complete program.
        let programHandle: GLuint = glCreateProgram()
        glAttachShader(programHandle, vertexShader)
        glAttachShader(programHandle, fragmentShader)
        glLinkProgram(programHandle)
        
        // Check for any errors.
        var linkSuccess: GLint = GLint()
        glGetProgramiv(programHandle, GLenum(GL_LINK_STATUS), &linkSuccess)
        if (linkSuccess == GL_FALSE) {
            print("Failed to create shader program!")
            var infolog = [GLchar](count: 100, repeatedValue: 0)
            var length : GLsizei = GLsizei()
            glGetProgramInfoLog(programHandle, 100, &length, &infolog)
            print(String.fromCString(&infolog))
            exit(1);
        }
        
        // Call glUseProgram to tell OpenGL to actually use this program when given vertex info.
        glUseProgram(programHandle)
        
        // Finally, call glGetAttribLocation to get a pointer to the input values for the vertex shader, so we
        //  can set them in code. Also call glEnableVertexAttribArray to enable use of these arrays (they are disabled by default).
        self.positionSlot = GLuint(glGetAttribLocation(programHandle, "Position"))
        self.uvSlot = GLuint(glGetAttribLocation(programHandle, "TexSource"))
        glEnableVertexAttribArray(self.positionSlot)
        glEnableVertexAttribArray(self.uvSlot)

        
        
        self.textureSlot = GLint(glGetUniformLocation(programHandle, "TextureSampler"));
        //Attach uniform in textureSlot to TEXTURE0
        glUniform1i(self.textureSlot, 0);
    }
    
    // Setup Vertex Buffer Objects
    func setupVBOs() {
        glGenVertexArraysOES(1, &VAO);
        glBindVertexArrayOES(VAO);
        
        glGenBuffers(1, &positionBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), positionBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), Vertices.size(), Vertices, GLenum(GL_STATIC_DRAW))
        
        glEnableVertexAttribArray(positionSlot)
        glVertexAttribPointer(positionSlot, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), nil)
        
        glGenBuffers(1, &uvBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), uvBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), Vertices.size(), Vertices, GLenum(GL_STATIC_DRAW))
        
        glEnableVertexAttribArray(uvSlot)
        glVertexAttribPointer(uvSlot, 2, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), UnsafePointer(bitPattern: sizeof(ImagePosition)))
        
        glGenBuffers(1, &indexBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), Indices.size(), Indices, GLenum(GL_STATIC_DRAW))
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArrayOES(0)
    }
    
    // Setup Vertex Buffer Objects
    func setupFaceIndices() {
        glGenVertexArraysOES(1, &VFaceAO);
        glBindVertexArrayOES(VFaceAO);
        
        glGenBuffers(1, &facePositionBuffer)
        glGenBuffers(1, &faceUvBuffer)
        glGenBuffers(1, &faceIndexBuffer)

        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArrayOES(0)
    }
    
    func setupAVCapture() {
        session = AVCaptureSession()
        
        //get from cam
        let videoDevice = AVCaptureDevice.devices()[1] as! AVCaptureDevice
        var input : AVCaptureDeviceInput? = nil
        do {
            input = try AVCaptureDeviceInput(device: videoDevice )
        } catch _ {
            print("Failed to get video input")
            exit(1);
        }
        do {
            try videoDevice.lockForConfiguration()
            videoDevice.activeVideoMaxFrameDuration = CMTimeMake(10, 240)
            videoDevice.activeVideoMinFrameDuration = CMTimeMake(10, 240)
            videoDevice.unlockForConfiguration()
        } catch _ {
            print("Could not set FPS to 24, continuing")
        }
        session?.addInput(input)
        
        var output : AVCaptureVideoDataOutput? = nil
        output = AVCaptureVideoDataOutput()
        guard let _ = output else {
            print("Failed to get video output")
            exit(1);
        }
        output?.alwaysDiscardsLateVideoFrames = true
        
        output!.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA), ]
        output?.setSampleBufferDelegate(self, queue: dispatch_get_main_queue())
        session?.addOutput(output)
        session?.commitConfiguration()
        session?.startRunning()
    }
    
    var lastTime : NSDate? = nil
    func captureOutput(captureOutput : AVCaptureOutput, didOutputSampleBuffer sampleBuffer: CMSampleBufferRef, fromConnection connection: AVCaptureConnection) {
        dispatch_async(dispatch_get_main_queue()) {
            self.videoTexture = nil
            CVOpenGLESTextureCacheFlush(self.textureCache!, 0);
            
            self.pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            guard let _ = self.pixelBuffer else {
                print("Failed to get pixel buffer")
                exit(1)
            }
            
            let width = CVPixelBufferGetWidth(self.pixelBuffer!)
            let height = CVPixelBufferGetHeight(self.pixelBuffer!)
            
            glActiveTexture(GLenum(GL_TEXTURE0))
            
            let ret = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                self.textureCache!,
                self.pixelBuffer!,
                nil,
                GLenum(GL_TEXTURE_2D),
                GLint(GL_RGBA),
                GLsizei(width),
                GLsizei(height),
                GLenum(GL_BGRA),
                GLenum(GL_UNSIGNED_BYTE),
                0,
                &self.videoTexture)
            if ret != kCVReturnSuccess {
                print("CVOpenGLESTextureCacheCreateTextureFromImage failed with code \(ret)")
                exit(1)
            }
            self.render()
        }
    }

    
    func setupTextureCache() {
        let cacheStatus = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, self.context, nil, &textureCache)
        if cacheStatus != kCVReturnSuccess {
            print("Creating texture cache failed with error \(cacheStatus)")
            exit(1)
        }
    }
    
    func uiImageFromPixelBuffer(pixelBuffer: CVPixelBufferRef) -> UIImage {
        let ciImage = CIImage(CVPixelBuffer: pixelBuffer)
        let temporaryContext = CIContext()
        let cgImage = temporaryContext.createCGImage(ciImage, fromRect: CGRectMake(0, 0, CGFloat(CVPixelBufferGetWidth(pixelBuffer)), CGFloat(CVPixelBufferGetHeight(pixelBuffer))))
        let uiImage = UIImage(CGImage: cgImage)
        return uiImage
    }
    
    func renderWholeImageToRenderTexture() {
        glBindVertexArrayOES(VAO)
        glViewport(0, 0, GLint(CVPixelBufferGetWidth(renderPB!)), GLint(CVPixelBufferGetHeight(renderPB!)));
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), CVOpenGLESTextureGetName(renderTex!), 0);
        glBindTexture(CVOpenGLESTextureGetTarget(videoTexture!), CVOpenGLESTextureGetName(videoTexture!))
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(Indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
        glBindVertexArrayOES(0)
    }
    
    func renderWholeImageToSmallTexture() {
        glBindVertexArrayOES(VAO)
        glViewport(0, 0, GLint(CVPixelBufferGetWidth(smallPixelBuffer!)), GLint(CVPixelBufferGetHeight(smallPixelBuffer!)));
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), CVOpenGLESTextureGetName(smallTexture!), 0);
        glBindTexture(CVOpenGLESTextureGetTarget(videoTexture!), CVOpenGLESTextureGetName(videoTexture!))
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(Indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
        glBindVertexArrayOES(0)
    }
    
    func renderWholeImageToFlipTexture() {
        glBindVertexArrayOES(VAO)
        glViewport(0, 0, GLint(CVPixelBufferGetWidth(flipPixelBuffer!)), GLint(CVPixelBufferGetHeight(flipPixelBuffer!)));
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), CVOpenGLESTextureGetName(flipTexture!), 0);
        glBindTexture(CVOpenGLESTextureGetTarget(videoTexture!), CVOpenGLESTextureGetName(videoTexture!))
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(Indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
        glBindVertexArrayOES(0)
    }
    
    func findFaces() {
        CVPixelBufferLockBaseAddress(self.smallPixelBuffer!, 0)
        let sWidth = CVPixelBufferGetWidth(self.smallPixelBuffer!)
        let sHeight = CVPixelBufferGetHeight(self.smallPixelBuffer!)
        let sRowSize = CVPixelBufferGetBytesPerRow(self.smallPixelBuffer!)
        let sPtr = UnsafeMutablePointer<UInt8>(CVPixelBufferGetBaseAddress(self.smallPixelBuffer!))
        let smallImg  = CamImage(pixels: sPtr, width: Int32(sWidth), height: Int32(sHeight), channels: Int32(4), rowSize: Int32(sRowSize))
        CVPixelBufferLockBaseAddress(self.flipPixelBuffer!, 0)
        let width = CVPixelBufferGetWidth(self.flipPixelBuffer!)
        let height = CVPixelBufferGetHeight(self.flipPixelBuffer!)
        let rowSize = CVPixelBufferGetBytesPerRow(self.flipPixelBuffer!)
        let ptr = UnsafeMutablePointer<UInt8>(CVPixelBufferGetBaseAddress(self.flipPixelBuffer!))
        let img  = CamImage(pixels: ptr, width: Int32(width), height: Int32(height), channels: Int32(4), rowSize: Int32(rowSize))
        
        let arrPoints = self.faceFinder.facesPointsInBigImage(img, andSmallImage: smallImg, withScale: Int32(smallTextureScale)) as! [[NSValue]]
        numfaces = arrPoints.count

        CVPixelBufferUnlockBaseAddress(self.smallPixelBuffer!, 0)
        CVPixelBufferUnlockBaseAddress(self.flipPixelBuffer!, 0)
        
        if arrPoints.count > 0 {
            let (indices, coordinates) = makeTriangulation(arrPoints)
            (currentIndices, faceVertices) = makeGLDataWithIndices(indices, andVertices: coordinates)
        } else {
            currentIndices = []
            faceVertices = []
        }
    }
    
    func makeGLDataWithIndices(indices : [PhiTriangle], andVertices vertices : [PhiPoint]) -> ([GLushort], [Coordinate]) {
        var glindices : [GLushort] = []
        for tri in indices {
            glindices.append(GLushort(tri.p0))
            glindices.append(GLushort(tri.p1))
            glindices.append(GLushort(tri.p2))
        }
        
        var glvertices : [Coordinate] = []
        
        // The first group of the vertices are faces, and we want to apply the warp
        for faceidx in 0..<numfaces {
            let offset = faceidx * 68
            let slice : [PhiPoint] = Array(vertices[offset..<offset + 68])
            let tmpArray = warper.doWarp(slice, warp: .PRETTY)
            for pidx in 0..<68 {
                let warped_point = tmpArray[pidx]
                let unwarped_point = slice[pidx]
                let xn_w = GLfloat(warped_point.x) / 1280.0
                let yn_w = GLfloat(warped_point.y) / 720.0
                let xn_u = GLfloat(unwarped_point.x) / 1280.0
                let yn_u = GLfloat(unwarped_point.y) / 720.0
                let u = GLfloat(xn_u)
                let v = GLfloat(1 - yn_u)
                let x = GLfloat(2 * xn_w - 1)
                let y = GLfloat(2 * yn_w - 1)
                let z = GLfloat(0)
                glvertices.append(Coordinate(xyz: (x, y, z), uv: (u, v)))
            }
        }
        for pidx in numfaces * 68..<vertices.count {
            let point = vertices[pidx]
            let xn = GLfloat(point.x) / 1280.0
            let yn = GLfloat(point.y) / 720.0
            let u = GLfloat(xn)
            let v = GLfloat(1 - yn)
            let x = GLfloat(2 * xn - 1)
            let y = GLfloat(2 * yn - 1)
            let z = GLfloat(0)
            glvertices.append(Coordinate(xyz: (x, y, z), uv: (u, v)))
        }
        
        
//        var mean_x = 0.0
//        var mean_y = 0.0
//        for pidx in edges.count..<vertices.count {
//            let point = vertices[pidx]
//            mean_x += Double(point.x)
//            mean_y += Double(point.y)
//        }
//        mean_x /= (67.0 * 1280)
//        mean_y /= (67.0 * 720)
//        for pidx in edges.count..<vertices.count {
//            let point = vertices[pidx]
//            let xn = GLfloat(point.x) / 1280.0
//            let yn = GLfloat(point.y) / 720.0
//            let u = GLfloat(xn)
//            let v = GLfloat(1 - yn)
//            var x = GLfloat(2 * xn - 1)
//            x = (x - GLfloat(mean_x)) * 1.07 + GLfloat(mean_x)
//            var y = GLfloat(2 * yn - 1)
//            y = (y - GLfloat(mean_y)) * 1.07 + GLfloat(mean_y)
//            let z = GLfloat(0)
//            glvertices.append(Coordinate(xyz: (x, y, z), uv: (u, v)))
//        }
        
        return (glindices, glvertices)
    }

    func makeTriangulation(rawFacePoints : [[NSValue]]) -> ([PhiTriangle], [PhiPoint]) {
        var allPoints : [PhiPoint] = []
        for points in rawFacePoints {
            allPoints.appendContentsOf(points.map {$0.PhiPointValue})
        }
        allPoints.appendContentsOf(edges)
        let triangulation = tidyIndices(allPoints, numEdges: edges.count, numFaces: rawFacePoints.count)
        return (triangulation, allPoints)
    }
    
    func setFaceVertices() {
        if faceVertices.count > 0 {
//            print("Binding \(faceVertices.count) face vertices and \(currentIndices.count) indices")
            glBindVertexArrayOES(VFaceAO);
            
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), facePositionBuffer)
            glBufferData(GLenum(GL_ARRAY_BUFFER), faceVertices.size(), faceVertices, GLenum(GL_STREAM_DRAW))
            glEnableVertexAttribArray(positionSlot)
            glVertexAttribPointer(positionSlot, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), nil)
            
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), faceUvBuffer)
            glBufferData(GLenum(GL_ARRAY_BUFFER), faceVertices.size(), faceVertices, GLenum(GL_STREAM_DRAW))
            glEnableVertexAttribArray(uvSlot)
            glVertexAttribPointer(uvSlot, 2, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), UnsafePointer(bitPattern: sizeof(ImagePosition)))
            
            glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), faceIndexBuffer)
            glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), currentIndices.size(), currentIndices, GLenum(GL_STREAM_DRAW))
            
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
            glBindVertexArrayOES(0)
        }
    }
    
    func renderFaceToRenderTexture() {
        glBindVertexArrayOES(VFaceAO)
        if faceVertices.count > 0 {
    
//            print("Rendering \(faceVertices.count) face vertices and \(currentIndices.count) indices")
            glViewport(0, 0, GLint(CVPixelBufferGetWidth(renderPB!)), GLint(CVPixelBufferGetHeight(renderPB!)));
            glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), CVOpenGLESTextureGetName(renderTex!), 0);
            
            glBindTexture(CVOpenGLESTextureGetTarget(videoTexture!), CVOpenGLESTextureGetName(videoTexture!))
            glClear(GLenum(GL_COLOR_BUFFER_BIT))
            glDrawElements(GLenum(GL_TRIANGLES), GLsizei(currentIndices.count), GLenum(GL_UNSIGNED_SHORT), nil)
        }
        glBindVertexArrayOES(0)
    }
    
    func renderRenderTextureToScreen() {
        glBindVertexArrayOES(VAO)
        glViewport(0, 0, GLint(self.frame.size.width * self.contentScaleFactor) , GLint(self.frame.size.height * self.contentScaleFactor));
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), self.colorRenderBuffer)
        glBindTexture(CVOpenGLESTextureGetTarget(renderTex!), CVOpenGLESTextureGetName(renderTex!))
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(Indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
        glBindVertexArrayOES(0)
    }
    func render() {
        renderWholeImageToSmallTexture()
        renderWholeImageToFlipTexture()
//        findFacesInImage()
//        findLandmarksInFaces()
        
        renderWholeImageToRenderTexture()
        
        findFaces()
        setFaceVertices()
        renderFaceToRenderTexture()

        renderRenderTextureToScreen()
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
}

///////////////////////////////////////

