//
//  Textures.swift
//  FaceWarpApp
//
//  Created by Thomas Nickson on 01/10/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

import Foundation
import CoreMedia
import CoreVideo

class TextureManager {
    
    // Top level stuff
    let context : EAGLContext
    let layer : CAEAGLLayer
    var textureCache : CVOpenGLESTextureCacheRef? = nil
    
    // References to Output render and framebuffers (for screen)
    var outputRenderBuffer : GLuint = GLuint()
    var outputFrameBuffer : GLuint = GLuint()
    
    // References to input video texture, live inside TEXTURE1
    var videoTexture : CVOpenGLESTextureRef? = nil
    var videoPixelBuffer : CVPixelBufferRef? = nil
    
    // References to Rotated render and textures - re-draw camera output here - live inside TEXTURE2
    var uprightTexture : CVOpenGLESTextureRef? = nil
    var uprightPixelBuffer : CVPixelBufferRef? = nil
    
    // References to Rotated render and textures - re-draw upright buffer smaller - live inside TEXTURE3
    var smallTexture : CVOpenGLESTextureRef? = nil
    var smallPixelBuffer : CVPixelBufferRef? = nil
    
    // Reference to HBlur texture - upright, blurred - live inside TEXTURE4
    var hblurTexture : GLuint = GLuint()
    var hblurwidth : Int = 0
    var hblurheight : Int = 0
    
    // Reference to VBlur texture - upright, blurred - lives inside TEXTURE5
    var vblurTexture : GLuint = GLuint()

    init?(withContext cntxt : EAGLContext, andLayer lyr : CAEAGLLayer) {
        context = cntxt
        layer = lyr
        
        // Setup a texture cache
        let cacheStatus = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, self.context, nil, &textureCache)
        if cacheStatus != kCVReturnSuccess {
            print("Creating texture cache failed with error \(cacheStatus)")
            return nil
        }
        setupScreen()
        setupNormalTextures()
    }
    
    var size : CGRect {
        return UIScreen.mainScreen().bounds
    }
    
    
    // MARK: loading data from a sample buffer (video) into OpenGL
    func loadTextureFromSampleBuffer(sampleBuffer: CMSampleBuffer) { // Video texture lives in TEXTURE0
        self.videoTexture = nil
        CVOpenGLESTextureCacheFlush(self.textureCache!, 0);
        
        self.videoPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        guard let _ = self.videoPixelBuffer else {
            print("Failed to get pixel buffer")
            exit(1)
        }
        let width = CVPixelBufferGetWidth(self.videoPixelBuffer!)
        let height = CVPixelBufferGetHeight(self.videoPixelBuffer!)
        
        glActiveTexture(GLenum(GL_TEXTURE1))
        let ret = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
            self.textureCache!,
            self.videoPixelBuffer!,
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
        
        glBindTexture(
            CVOpenGLESTextureGetTarget(videoTexture!),
            CVOpenGLESTextureGetName(videoTexture!)
        )
        glActiveTexture(GLenum(GL_TEXTURE0))
    }
    func bindVideoTextureToSlot(textureSlot : GLint) {
        glUniform1i(textureSlot, 1)
    }
    
    func saveIntermediateTexture() {
        if let pb = uprightPixelBuffer {
            savePixelBuffer(pb)
        }
    }
    
    func saveSmallTexture() {
        if let pb = smallPixelBuffer {
            savePixelBuffer(pb)
        }
    }
    
    // MARK: output buffers for iOS
    func setupScreen() {
        glGenRenderbuffers(1, &outputRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), outputRenderBuffer)
        context.renderbufferStorage(Int(GL_RENDERBUFFER), fromDrawable:self.layer)
        glGenFramebuffers(1, &outputFrameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), outputFrameBuffer)
    }
    func bindScreen() {
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), outputRenderBuffer)
    }
    
    // MARK: generate buffer for flipped textures
    func makeUprightPixelBufferWithWidth(width : Int, andHeight height : Int) {
        uprightPixelBuffer = nil
        uprightTexture = nil
        CVOpenGLESTextureCacheFlush(textureCache!, 0)
        let size = CGSizeMake(CGFloat(width), CGFloat(height))
        
        glActiveTexture(GLenum(GL_TEXTURE2)) // upright texture lives in texture 2
        generatePixelBuffer(&uprightPixelBuffer, andTexture: &uprightTexture, withSize: size)
        glBindTexture(CVOpenGLESTextureGetTarget(uprightTexture!), CVOpenGLESTextureGetName(uprightTexture!))
        glActiveTexture(GLenum(GL_TEXTURE0))
    }
    func bindUprightTextureAsOutput() {
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), CVOpenGLESTextureGetName(uprightTexture!), 0);
    }
    func bindUprightTextureToSlot(textureSlot : GLint) {
        glUniform1i(textureSlot, 2)
    }
    func setViewPortForUprightTexture() {
        if let pb = uprightPixelBuffer {
            setViewPortForTexture(pb)
        }
    }
    
    // MARK: generate buffer for smaller textures
    func makeSmallerPixelBufferWithWidth(inWidth : Int, andHeight inHeight : Int, andScale scale : Int = 2) {
        smallPixelBuffer = nil
        smallTexture = nil
        CVOpenGLESTextureCacheFlush(textureCache!, 0)
        
        let height = inHeight / scale
        let width = inWidth / scale
        
        CVOpenGLESTextureCacheFlush(textureCache!, 0)
        let size = CGSizeMake(CGFloat(width), CGFloat(height))
        
        glActiveTexture(GLenum(GL_TEXTURE3)) // upright texture lives in texture 2
        generatePixelBuffer(&smallPixelBuffer, andTexture: &smallTexture, withSize: size)
        glBindTexture(CVOpenGLESTextureGetTarget(smallTexture!), CVOpenGLESTextureGetName(smallTexture!))
        glActiveTexture(GLenum(GL_TEXTURE0))
    }
    func bindSmallerTextureAsOutput() {
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), CVOpenGLESTextureGetName(smallTexture!), 0);
    }
    func bindSmallerTextureToSlot(textureSlot : GLint) {
        glUniform1i(textureSlot, 3)
    }
    func setViewPortForSmallerTexture() {
        if let pb = smallPixelBuffer {
            setViewPortForTexture(pb)
        }
    }
    
    // MAKL: setup for non-CVPixel backed textures
    func setupNormalTextures() {
        glGenTextures(1, &hblurTexture)
        glGenTextures(1, &vblurTexture)
    }
    
    // MARK: generate buffer for hblur - GL_TEXTURE4
    func makeHBlurTexture(inWidth : Int, andHeight inHeight : Int, andScale scale : Int = 2) {
        hblurwidth = inWidth / scale
        hblurheight = inHeight / scale
        glActiveTexture(GLenum(GL_TEXTURE4))
        glBindTexture(GLenum(GL_TEXTURE_2D), hblurTexture)
        glTexImage2D(
            GLenum(GL_TEXTURE_2D),
            0,
            GLint(GL_RGBA),
            GLsizei(hblurwidth),
            GLsizei(hblurheight),
            0,
            GLenum(GL_RGBA),
            GLenum(GL_UNSIGNED_BYTE),
            nil);
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
    }
    func bindHBlurTextureAsOutput() {
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), hblurTexture, 0);
    }
    func bindHBlurTextureToSlot(textureSlot : GLint) {
        glUniform1i(textureSlot, 4)
    }
    func setViewPortForHBlurTexture() {
        glViewport(
            0,
            0,
            GLsizei(hblurwidth),
            GLsizei(hblurwidth)
        )
    }
    
    // MARK: Setupviewport to fill a given texture
    func setViewPortForTexture(pb : CVPixelBufferRef) {
        glViewport(
            0,
            0,
            GLsizei(CVPixelBufferGetWidth(pb)),
            GLsizei(CVPixelBufferGetHeight(pb))
        )
    }
    
    // MARK: Save a given pixel buffer to camera roll
    func savePixelBuffer(pb : CVPixelBufferRef) {
        let ciImage = CIImage(CVPixelBuffer: pb)
        let tmpContext = CIContext()
        let width = CGFloat(CVPixelBufferGetWidth(pb))
        let height = CGFloat(CVPixelBufferGetHeight(pb))
        let videoImage = tmpContext.createCGImage(ciImage, fromRect: CGRectMake(0, 0, width, height))
        let uiImage = UIImage(CGImage: videoImage)
        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
    }
    
    func generatePixelBuffer(inout buffer : CVPixelBufferRef?, inout andTexture texture : CVOpenGLESTextureRef?, withSize size : CGSize) {
        let options = [
            kCVPixelBufferCGImageCompatibilityKey as String: false,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: false,
            kCVPixelFormatOpenGLESCompatibility as String: true,
            kCVPixelBufferIOSurfacePropertiesKey as String: [NSObject: NSObject]()
        ]
        
        let height = size.height
        let width = size.width
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(width), Int(height), kCVPixelFormatType_32BGRA, options, &buffer)
        if status != kCVReturnSuccess {
            print("Pixel buffer with image failed creating CVPixelBuffer with error \(status)")
            exit(1)
        }
        guard let _ = uprightPixelBuffer else {
            print("Pixel buffer did not allocate")
            exit(1)
        }
        let res = CVOpenGLESTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            textureCache!,
            buffer!,
            nil,
            GLenum(GL_TEXTURE_2D),
            GLint(GL_RGBA),
            GLsizei(width),
            GLsizei(height),
            GLenum(GL_BGRA),
            GLenum(GL_UNSIGNED_BYTE),
            0,
            &texture)
        guard res == kCVReturnSuccess else {
            print("Create texture from image failed with code \(res)")
            exit(1)
        }
    }
    
}




//
//func setupFlipTexture() {
//    let options = [
//        kCVPixelBufferCGImageCompatibilityKey as String: false,
//        kCVPixelBufferCGBitmapContextCompatibilityKey as String: false,
//        kCVPixelFormatOpenGLESCompatibility as String: true,
//        kCVPixelBufferIOSurfacePropertiesKey as String: [NSObject: NSObject]()
//    ]
//    
//    let height = 1280
//    let width = 720
//    
//    let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(height), Int(width), kCVPixelFormatType_32BGRA, options, &flipPixelBuffer)
//    if status != kCVReturnSuccess {
//        print("Pixel buffer with image failed creating CVPixelBuffer with error \(status)")
//        exit(1)
//    }
//    guard let _ = flipPixelBuffer else {
//        print("Pixel buffer did not allocate")
//        exit(1)
//    }
//    
//    var texCacheRef : CVOpenGLESTextureCacheRef?
//    let cacheStatus = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, self.context, nil, &texCacheRef)
//    if cacheStatus != kCVReturnSuccess {
//        print("Creating texture cache failed with error \(cacheStatus)")
//        exit(1)
//    }
//    
//    let res = CVOpenGLESTextureCacheCreateTextureFromImage(
//        kCFAllocatorDefault,
//        texCacheRef!,
//        flipPixelBuffer!,
//        nil,
//        GLenum(GL_TEXTURE_2D),
//        GLint(GL_RGBA),
//        GLsizei(height),
//        GLsizei(width),
//        GLenum(GL_BGRA),
//        GLenum(GL_UNSIGNED_BYTE),
//        0,
//        &flipTexture)
//    guard res == kCVReturnSuccess else {
//        print("Create texture from image failed with code \(res)")
//        exit(1)
//    }
//    glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), CVOpenGLESTextureGetName(flipTexture!), 0);
//}
//
//func setupSmallTexture() {
//    let options = [
//        kCVPixelBufferCGImageCompatibilityKey as String: false,
//        kCVPixelBufferCGBitmapContextCompatibilityKey as String: false,
//        kCVPixelFormatOpenGLESCompatibility as String: true,
//        kCVPixelBufferIOSurfacePropertiesKey as String: [NSObject: NSObject]()
//    ]
//    
//    let height = 1280 / smallTextureScale
//    let width = 720 / smallTextureScale
//    
//    let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(height), Int(width), kCVPixelFormatType_32BGRA, options, &smallPixelBuffer)
//    if status != kCVReturnSuccess {
//        print("Pixel buffer with image failed creating CVPixelBuffer with error \(status)")
//        exit(1)
//    }
//    guard let _ = smallPixelBuffer else {
//        print("Pixel buffer did not allocate")
//        exit(1)
//    }
//    
//    var texCacheRef : CVOpenGLESTextureCacheRef?
//    let cacheStatus = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, self.context, nil, &texCacheRef)
//    if cacheStatus != kCVReturnSuccess {
//        print("Creating texture cache failed with error \(cacheStatus)")
//        exit(1)
//    }
//    
//    let res = CVOpenGLESTextureCacheCreateTextureFromImage(
//        kCFAllocatorDefault,
//        texCacheRef!,
//        smallPixelBuffer!,
//        nil,
//        GLenum(GL_TEXTURE_2D),
//        GLint(GL_RGBA),
//        GLsizei(height),
//        GLsizei(width),
//        GLenum(GL_BGRA),
//        GLenum(GL_UNSIGNED_BYTE),
//        0,
//        &smallTexture)
//    guard res == kCVReturnSuccess else {
//        print("Create texture from image failed with code \(res)")
//        exit(1)
//    }
//    
//    glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), CVOpenGLESTextureGetName(smallTexture!), 0);
//}
//
