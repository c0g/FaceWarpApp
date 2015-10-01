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
    let size : CGRect
    let context : EAGLContext
    let layer : CAEAGLLayer
    var textureCache : CVOpenGLESTextureCacheRef? = nil
    
    // References to Output render and framebuffers (for screen)
    var outputRenderBuffer : GLuint = GLuint()
    var outputFrameBuffer : GLuint = GLuint()
    
    // References to input video texture, live inside TEXTURE0
    var videoTexture : CVOpenGLESTextureRef? = nil
    var videoPixelBuffer : CVPixelBufferRef? = nil
    
    // References to Rotated render and textures (re-draw camera output here)
    
    
    // References to textures
    var rotatedTexture : Texture? = nil // Re-draw the input into this texture. Used as the source for other draw calls, and for dlib face point localisation.
    var smallTexture : Texture? = nil // Re-draw the rotated texture into this texture at 1/4 size. Used for dlib face box detection. Re-used as a blur texture.
    var smallBlurTexture : Texture? = nil // Intermediate texture to draw a two part blur into.
    var mouthTexture : Texture? = nil // A small, 50x50 texture to draw the mouth into for tooth threshold analysis
    var outputTexture : PixelBufferTexture? = nil // We use this as a source for video and image capturing. Allows us to transform the render buffer.

    init?(withContext cntxt : EAGLContext, andLayer lyr : CAEAGLLayer) {
        size = UIScreen.mainScreen().bounds
        context = cntxt
        layer = lyr
        
        // Setup a texture cache
        let cacheStatus = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, self.context, nil, &textureCache)
        if cacheStatus != kCVReturnSuccess {
            print("Creating texture cache failed with error \(cacheStatus)")
            return nil
        }
        
        setupOutputBuffers()
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
        glActiveTexture(GLenum(GL_TEXTURE0))
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
    }
    
    func bindVideoTextureToSlot(textureSlot: GLint) {
        glUniform1i(textureSlot, GL_TEXTURE0)
    }
    
    // MARK: output buffers for iOS
    func setupOutputBuffers() {
        glGenRenderbuffers(1, &outputRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), outputRenderBuffer)
        context.renderbufferStorage(Int(GL_RENDERBUFFER), fromDrawable:self.layer)
        glGenFramebuffers(1, &outputFrameBuffer);
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), outputFrameBuffer);
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), outputRenderBuffer)
    }
    func bindOutputBuffer() {
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), outputFrameBuffer);
        glViewport(0,0, GLsizei(size.width * self.layer.contentsScale), GLsizei(size.height * self.layer.contentsScale));
    }
    
}



//
//
//func setupRenderTexture() {
//    let options = [
//        kCVPixelBufferCGImageCompatibilityKey as String: false,
//        kCVPixelBufferCGBitmapContextCompatibilityKey as String: false,
//        kCVPixelFormatOpenGLESCompatibility as String: true,
//        kCVPixelBufferIOSurfacePropertiesKey as String: [NSObject: NSObject]()
//    ]
//    
//    let height = UIScreen.mainScreen().bounds.height * self.contentScaleFactor
//    let width = UIScreen.mainScreen().bounds.width * self.contentScaleFactor
//    
//    let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(height), Int(width), kCVPixelFormatType_32BGRA, options, &renderPB)
//    if status != kCVReturnSuccess {
//        print("Pixel buffer with image failed creating CVPixelBuffer with error \(status)")
//        exit(1)
//    }
//    guard let _ = renderPB else {
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
//        renderPB!,
//        nil,
//        GLenum(GL_TEXTURE_2D),
//        GLint(GL_RGBA),
//        GLsizei(height),
//        GLsizei(width),
//        GLenum(GL_BGRA),
//        GLenum(GL_UNSIGNED_BYTE),
//        0,
//        &renderTex)
//    guard res == kCVReturnSuccess else {
//        print("Create texture from image failed with code \(res)")
//        exit(1)
//    }
//    
//    renderTexName = CVOpenGLESTextureGetName(renderTex!)
//    glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), CVOpenGLESTextureGetName(renderTex!), 0);
//}
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
