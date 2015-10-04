//
//  Renderer.swift
//  FaceWarpApp
//
//  Created by Thomas Nickson on 01/10/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

import Foundation
import AVFoundation
import CoreVideo

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

class Renderer : NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let context : EAGLContext
    let layer : CAEAGLLayer
    
    var textureManager : TextureManager?
    var shaderManager : ShaderManager?
    var vertexManager : VertexManager?
    let faceDetector : FaceFinder = FaceFinder()
    
    var orientation : UIInterfaceOrientation = UIInterfaceOrientation.Unknown
    var pastOrientation : UIInterfaceOrientation = UIInterfaceOrientation.Unknown
    
    init(withContext c: EAGLContext, andLayer l: CAEAGLLayer) {
        context = c
        layer = l
        super.init()
        self.textureManager = TextureManager(withContext: context, andLayer: layer)
        self.shaderManager = ShaderManager()
        self.vertexManager = VertexManager()
    }

    func captureOutput(
        captureOutput : AVCaptureOutput,
        didOutputSampleBuffer sampleBuffer: CMSampleBufferRef,
        fromConnection connection: AVCaptureConnection
        ) {
        textureManager!.loadTextureFromSampleBuffer(sampleBuffer)
        render()
    }
    
    func preprocessRender() {
        let (xyzSlot, uvSlot, textureSlot) = shaderManager!.activatePassThroughShader()
        
        let width = CVPixelBufferGetWidth(textureManager!.videoPixelBuffer!)
        let height = CVPixelBufferGetHeight(textureManager!.videoPixelBuffer!)
        
        switch orientation {
        case pastOrientation:
            break
        case .LandscapeLeft:
            vertexManager!.fillPreprocessVBO(forFlip: .HORIZONTAL, andRotate90: false)
            textureManager!.makeUprightPixelBufferWithWidth(width, andHeight: height)
        case .LandscapeRight:
            vertexManager!.fillPreprocessVBO(forFlip: .VERTICAL, andRotate90: false)
            textureManager!.makeUprightPixelBufferWithWidth(width, andHeight: height)
        case .Portrait:
            vertexManager!.fillPreprocessVBO(forFlip: .VERTICAL, andRotate90: true)
            textureManager!.makeUprightPixelBufferWithWidth(height, andHeight: width)
        case .PortraitUpsideDown:
            vertexManager!.fillPreprocessVBO(forFlip: .NONE, andRotate90: true)
            textureManager!.makeUprightPixelBufferWithWidth(height, andHeight: width)
        case .Unknown:
            vertexManager!.fillPreprocessVBO(forFlip: .NONE, andRotate90: false)
            textureManager!.makeUprightPixelBufferWithWidth(width, andHeight: height)
        }
        
        let (num, type) = vertexManager!.bindPreprocessVBO(withPositionSlot: xyzSlot, andUVSlot: uvSlot)
        glUniform1i(textureSlot, 1)
        textureManager!.bindUprightTextureAsOutput()
        glViewport(
            0,
            0,
            GLsizei(CVPixelBufferGetWidth(textureManager!.uprightPixelBuffer!)),
            GLsizei(CVPixelBufferGetHeight(textureManager!.uprightPixelBuffer!))
        )
        glDrawElements(GLenum(GL_TRIANGLES), num, type, nil)
        vertexManager!.unbindPreprocessVBO(fromPositionSlot: xyzSlot, andUVSlot: uvSlot)
    }
    
    func renderToSmallTexture() {
        let (xyzSlot, uvSlot, textureSlot) = shaderManager!.activatePassThroughShader()
        
        
        let width = CVPixelBufferGetWidth(textureManager!.videoPixelBuffer!)
        let height = CVPixelBufferGetHeight(textureManager!.videoPixelBuffer!)
        
        switch orientation {
        case pastOrientation:
            break
        case .LandscapeLeft:
            textureManager!.makeSmallerPixelBufferWithWidth(width, andHeight: height)
        case .LandscapeRight:
            textureManager!.makeSmallerPixelBufferWithWidth(width, andHeight: height)
        case .Portrait:
            textureManager!.makeSmallerPixelBufferWithWidth(height, andHeight: width)
        case .PortraitUpsideDown:
            textureManager!.makeSmallerPixelBufferWithWidth(height, andHeight: width)
        case .Unknown:
            textureManager!.makeSmallerPixelBufferWithWidth(width, andHeight: height)
        }
        
        textureManager!.bindSmallerTextureAsOutput()
        let (num, type) = vertexManager!.bindPassVBO(withPositionSlot: xyzSlot, andUVSlot: uvSlot)
        glUniform1i(textureSlot, 2) // upright texture is in GL_TEXTURE2
        glViewport(
            0,
            0,
            GLsizei(CVPixelBufferGetWidth(textureManager!.smallPixelBuffer!)),
            GLsizei(CVPixelBufferGetHeight(textureManager!.smallPixelBuffer!))
        )
        glDrawElements(GLenum(GL_TRIANGLES), num, type, nil)
        vertexManager!.unbindPassVBO(fromPositionSlot: xyzSlot, andUVSlot: uvSlot)
    }
    
    func renderToScreen() {
        let (xyzSlot, uvSlot, textureSlot) = shaderManager!.activatePassThroughShader()
        
        switch orientation {
        case pastOrientation:
            break
        case .LandscapeLeft:
            vertexManager!.fillPostprocessVBO(forFlip: .BOTH, andRotate90: false)
        case .LandscapeRight:
            vertexManager!.fillPostprocessVBO(forFlip: .VERTICAL, andRotate90: false)
        case .Portrait:
            vertexManager!.fillPostprocessVBO(forFlip: .BOTH, andRotate90: false)
        case .PortraitUpsideDown:
            vertexManager!.fillPostprocessVBO(forFlip: .NONE, andRotate90: true)
        case .Unknown:
            vertexManager!.fillPostprocessVBO(forFlip: .NONE, andRotate90: false)
        }
        
        textureManager!.bindScreen()
        
        let width = UIScreen.mainScreen().bounds.width * UIScreen.mainScreen().scale
        let height = UIScreen.mainScreen().bounds.height * UIScreen.mainScreen().scale
        
        switch orientation {
        case .LandscapeLeft:
            glViewport(0, 0, GLsizei(height), GLsizei(width))
        case .LandscapeRight:
            glViewport(0, 0, GLsizei(height), GLsizei(width))
        case .Portrait:
            glViewport(0, 0, GLsizei(width), GLsizei(height))
        case .PortraitUpsideDown:
            glViewport(0, 0, GLsizei(width), GLsizei(height))
        case .Unknown:
            glViewport(0, 0, GLsizei(width), GLsizei(height))
        }
        
        let (num, type) = vertexManager!.bindPostprocessVBO(withPositionSlot: xyzSlot, andUVSlot: uvSlot)
        glUniform1i(textureSlot, 2)
        glDrawElements(GLenum(GL_TRIANGLES), num, type, nil)
        vertexManager!.unbindPostprocessVBO(fromPositionSlot: xyzSlot, andUVSlot: uvSlot)
    }
    func render() {
        glClear(GLenum(GL_COLOR_BUFFER_BIT))
        let _pastOrientation = orientation
        orientation = UIApplication.sharedApplication().statusBarOrientation
        preprocessRender()
        glFinish()
        renderToSmallTexture()
        renderToScreen()
        pastOrientation = _pastOrientation
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
}
//
//func captureOutput(captureOutput : AVCaptureOutput, didOutputSampleBuffer sampleBuffer: CMSampleBufferRef, fromConnection connection: AVCaptureConnection) {
//    dispatch_async(dispatch_get_main_queue()) {
//        self.videoTexture = nil
//        CVOpenGLESTextureCacheFlush(self.textureCache!, 0);
//        
//        self.pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
//        guard let _ = self.pixelBuffer else {
//            print("Failed to get pixel buffer")
//            exit(1)
//        }
//        
//        let width = CVPixelBufferGetWidth(self.pixelBuffer!)
//        let height = CVPixelBufferGetHeight(self.pixelBuffer!)
//        
//        glActiveTexture(GLenum(GL_TEXTURE0))
//        
//        let ret = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
//            self.textureCache!,
//            self.pixelBuffer!,
//            nil,
//            GLenum(GL_TEXTURE_2D),
//            GLint(GL_RGBA),
//            GLsizei(width),
//            GLsizei(height),
//            GLenum(GL_BGRA),
//            GLenum(GL_UNSIGNED_BYTE),
//            0,
//            &self.videoTexture)
//        if ret != kCVReturnSuccess {
//            print("CVOpenGLESTextureCacheCreateTextureFromImage failed with code \(ret)")
//            exit(1)
//        }
//        self.render()
//    }
//func renderWholeImageToRenderTexture() {
//    glBindVertexArrayOES(VAO)
//    glViewport(0, 0, GLint(CVPixelBufferGetWidth(renderPB!)), GLint(CVPixelBufferGetHeight(renderPB!)));
//    glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), CVOpenGLESTextureGetName(renderTex!), 0);
//    glBindTexture(CVOpenGLESTextureGetTarget(videoTexture!), CVOpenGLESTextureGetName(videoTexture!))
//    glDrawElements(GLenum(GL_TRIANGLES), GLsizei(Indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
//    glBindVertexArrayOES(0)
//}
//
//func renderWholeImageToSmallTexture() {
//    glBindVertexArrayOES(VAO)
//    glViewport(0, 0, GLint(CVPixelBufferGetWidth(smallPixelBuffer!)), GLint(CVPixelBufferGetHeight(smallPixelBuffer!)));
//    glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), CVOpenGLESTextureGetName(smallTexture!), 0);
//    glBindTexture(CVOpenGLESTextureGetTarget(videoTexture!), CVOpenGLESTextureGetName(videoTexture!))
//    glDrawElements(GLenum(GL_TRIANGLES), GLsizei(Indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
//    glBindVertexArrayOES(0)
//}
//
//func renderWholeImageToFlipTexture() {
//    glBindVertexArrayOES(VAO)
//    glViewport(0, 0, GLint(CVPixelBufferGetWidth(flipPixelBuffer!)), GLint(CVPixelBufferGetHeight(flipPixelBuffer!)));
//    glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), CVOpenGLESTextureGetName(flipTexture!), 0);
//    glBindTexture(CVOpenGLESTextureGetTarget(videoTexture!), CVOpenGLESTextureGetName(videoTexture!))
//    glDrawElements(GLenum(GL_TRIANGLES), GLsizei(Indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
//    glBindVertexArrayOES(0)
//}
//
//func renderFaceToRenderTexture() {
//    glBindVertexArrayOES(VFaceAO)
//    if faceVertices.count > 0 {
//        
//        //            print("Rendering \(faceVertices.count) face vertices and \(currentIndices.count) indices")
//        glViewport(0, 0, GLint(CVPixelBufferGetWidth(renderPB!)), GLint(CVPixelBufferGetHeight(renderPB!)));
//        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), CVOpenGLESTextureGetName(renderTex!), 0);
//        
//        glBindTexture(CVOpenGLESTextureGetTarget(videoTexture!), CVOpenGLESTextureGetName(videoTexture!))
//        glClear(GLenum(GL_COLOR_BUFFER_BIT))
//        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(currentIndices.count), GLenum(GL_UNSIGNED_SHORT), nil)
//    }
//    glBindVertexArrayOES(0)
//}
//
//func renderRenderTextureToScreen() {
//    glBindVertexArrayOES(VAO)
//    
//    glViewport(0, 0, GLint(self.frame.size.width * self.contentScaleFactor) , GLint(self.frame.size.height * self.contentScaleFactor));
//    glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), self.colorRenderBuffer)
//    glBindTexture(CVOpenGLESTextureGetTarget(renderTex!), CVOpenGLESTextureGetName(renderTex!))
//    glDrawElements(GLenum(GL_TRIANGLES), GLsizei(Indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
//    glBindVertexArrayOES(0)
//}
//func render() {
//    activateStandardShader()
//    
//    renderWholeImageToSmallTexture()
//    renderWholeImageToFlipTexture()
//    
//    renderWholeImageToRenderTexture()
//    
//    findFaces()
//    setFaceVertices()
//    activateHorizontalBlurShader()
//    setScaleInShader(gaussianHorizontalProgramHandle, toValue: 1)
//    renderFaceToRenderTexture()
//    
//    activateStandardShader()
//    renderRenderTextureToScreen()
//    self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
//}