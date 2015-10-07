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
    
    var doFaceBlur : Bool = true
    var captureNext : Bool = false
    
    var textureManager : TextureManager?
    var shaderManager : ShaderManager?
    var vertexManager : VertexManager?
    let faceDetector : FaceFinder = FaceFinder()
    let warper : Warper = Warper()
    
    let scale = 2 // how much we shrink small image by
    
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
                    fromConnection connection: AVCaptureConnection) {
        textureManager!.loadTextureFromSampleBuffer(sampleBuffer)
        render()
    }
    
    func setupForOrientation(withScale scale : Int = 2) {
        
        let vwidth = CVPixelBufferGetWidth(textureManager!.videoPixelBuffer!)
        let vheight = CVPixelBufferGetHeight(textureManager!.videoPixelBuffer!)
        
        switch orientation {
        case pastOrientation:
            break
        case .LandscapeLeft:
            vertexManager!.fillPreprocessVBO(forFlip: .HORIZONTAL, andRotate90: false)
            vertexManager!.fillPostprocessVBO(forFlip: .BOTH, andRotate90: false)
            textureManager!.makeUprightPixelBuffer(withWidth: vwidth, andHeight: vheight)
            textureManager!.makeOutputPixelBuffer(withWidth: vwidth, andHeight: vheight)
            textureManager!.makeSmallerPixelBuffer(withWidth: vwidth, andHeight: vheight, andScale: scale)
            textureManager!.makeHBlurTexture(withWidth: vwidth, andHeight: vheight, andScale: scale)
            textureManager!.makeVBlurTexture(withWidth: vwidth, andHeight: vheight, andScale: scale)
        case .LandscapeRight:
            vertexManager!.fillPreprocessVBO(forFlip: .VERTICAL, andRotate90: false)
            vertexManager!.fillPostprocessVBO(forFlip: .VERTICAL, andRotate90: false)
            textureManager!.makeUprightPixelBuffer(withWidth: vwidth, andHeight: vheight)
            textureManager!.makeOutputPixelBuffer(withWidth: vwidth, andHeight: vheight)
            textureManager!.makeSmallerPixelBuffer(withWidth: vwidth, andHeight: vheight, andScale: scale)
            textureManager!.makeHBlurTexture(withWidth: vwidth, andHeight: vheight, andScale: scale)
            textureManager!.makeVBlurTexture(withWidth: vwidth, andHeight: vheight, andScale: scale)
        case .Portrait:
            vertexManager!.fillPreprocessVBO(forFlip: .VERTICAL, andRotate90: true)
            vertexManager!.fillPostprocessVBO(forFlip: .BOTH, andRotate90: false)
            textureManager!.makeUprightPixelBuffer(withWidth: vheight, andHeight: vwidth)
            textureManager!.makeOutputPixelBuffer(withWidth: vheight, andHeight: vwidth)
            textureManager!.makeSmallerPixelBuffer(withWidth: vheight, andHeight: vwidth, andScale: scale)
            textureManager!.makeHBlurTexture(withWidth: vheight, andHeight: vwidth, andScale: scale)
            textureManager!.makeVBlurTexture(withWidth: vwidth, andHeight: vheight, andScale: scale)
        case .PortraitUpsideDown:
            vertexManager!.fillPreprocessVBO(forFlip: .NONE, andRotate90: true)
            vertexManager!.fillPostprocessVBO(forFlip: .NONE, andRotate90: true)
            textureManager!.makeUprightPixelBuffer(withWidth: vheight, andHeight: vwidth)
            textureManager!.makeOutputPixelBuffer(withWidth: vheight, andHeight: vwidth)
            textureManager!.makeSmallerPixelBuffer(withWidth: vheight, andHeight: vwidth, andScale: scale)
            textureManager!.makeHBlurTexture(withWidth: vheight, andHeight: vwidth, andScale: scale)
            textureManager!.makeVBlurTexture(withWidth: vwidth, andHeight: vheight, andScale: scale)
        case .Unknown:
            vertexManager!.fillPreprocessVBO(forFlip: .NONE, andRotate90: false)
            vertexManager!.fillPostprocessVBO(forFlip: .NONE, andRotate90: false)
            textureManager!.makeUprightPixelBuffer(withWidth: vwidth, andHeight: vheight)
            textureManager!.makeOutputPixelBuffer(withWidth: vwidth, andHeight: vheight)
            textureManager!.makeSmallerPixelBuffer(withWidth: vwidth, andHeight: vheight, andScale: scale)
            textureManager!.makeHBlurTexture(withWidth: vwidth, andHeight: vheight, andScale: scale)
            textureManager!.makeVBlurTexture(withWidth: vwidth, andHeight: vheight, andScale: scale)
        }
    }
    
    func preprocessRender() {
        let (xyzSlot, uvSlot, alphaSlot, textureSlot) = shaderManager!.activatePassThroughShader()
        let (num, type) = vertexManager!.bindPreprocessVBO(withPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
        textureManager!.bindVideoTextureToSlot(textureSlot)
        
        // Render real size, upright
        textureManager!.bindUprightTextureAsOutput()
        textureManager!.setViewPortForUprightTexture()
        glDrawElements(GLenum(GL_TRIANGLES), num, type, nil)
        
        downSizeBlurFilter()
        
        vertexManager!.unbindPreprocessVBO(fromPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
    }
    
    func downSizeBlurFilter() {
        
        let origHeight = textureManager!.uprightHeight
        let origWidth = textureManager!.uprightWidth
        
        var (xyzSlot, uvSlot, alphaSlot, textureSlot) = shaderManager!.activateHAvgShader(forHRes: GLfloat(origWidth))
        var (num, type) = vertexManager!.bindPassVBO(withPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
        
        textureManager!.bindUprightTextureToSlot(textureSlot)
        textureManager!.bindHBlurTextureAsOutput()
        textureManager!.setViewPortForHBlurTexture()
        glDrawElements(GLenum(GL_TRIANGLES), num, type, nil)
        vertexManager!.unbindPassVBO(fromPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
        
        (xyzSlot, uvSlot, alphaSlot, textureSlot) = shaderManager!.activateVAvgShader(forVRes: GLfloat(origHeight))
        (num, type) = vertexManager!.bindPassVBO(withPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
        
        textureManager!.bindHBlurTextureToSlot(textureSlot)
        textureManager!.bindSmallerTextureAsOutput()
        textureManager!.setViewPortForSmallerTexture()
        glDrawElements(GLenum(GL_TRIANGLES), num, type, nil)
        vertexManager!.unbindPassVBO(fromPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
        
        
    }
    
    func hblurRender() {
        let (xyzSlot, uvSlot, alphaSlot, textureSlot) = shaderManager!.activateHBlurShader(withScale: 1.0)
        let (num, type) = vertexManager!.bindPassVBO(withPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
        
        textureManager!.bindSmallerTextureToSlot(textureSlot)
        textureManager!.bindHBlurTextureAsOutput()
        textureManager!.setViewPortForHBlurTexture()
        glDrawElements(GLenum(GL_TRIANGLES), num, type, nil)
        vertexManager!.unbindPassVBO(fromPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
        
    }
    
    func vblurRender() {
        let (xyzSlot, uvSlot, alphaSlot, textureSlot) = shaderManager!.activateVBlurShader(withScale: 1.0)
        let (num, type) = vertexManager!.bindPassVBO(withPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
        
        textureManager!.bindHBlurTextureToSlot(textureSlot)
        textureManager!.bindVBlurTextureAsOutput()
        textureManager!.setViewPortForVBlurTexture()
        glDrawElements(GLenum(GL_TRIANGLES), num, type, nil)
        vertexManager!.unbindPassVBO(fromPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
    }
    
    func blurRender() {
        hblurRender()
        vblurRender()
    }
    
    func blurToOutput() {
        let (xyzSlot, uvSlot, alphaSlot, textureSlot) = shaderManager!.activateVBlurShader(withScale: 1.0)
        let (num, type) = vertexManager!.bindPassVBO(withPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
        textureManager!.bindVBlurTextureToSlot(textureSlot)
        textureManager!.bindOutputTextureAsOutput()
        textureManager!.setViewPortForOutputTexture()
        glDrawElements(GLenum(GL_TRIANGLES), num, type, nil)
        vertexManager!.unbindPassVBO(fromPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
    }
    
    func clearToOutput() {
        let (xyzSlot, uvSlot, alphaSlot, textureSlot) = shaderManager!.activatePassThroughShader()
        let (num, type) = vertexManager!.bindPassVBO(withPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
        textureManager!.bindUprightTextureToSlot(textureSlot)
        textureManager!.bindOutputTextureAsOutput()
        textureManager!.setViewPortForOutputTexture()
        glDrawElements(GLenum(GL_TRIANGLES), num, type, nil)
        vertexManager!.unbindPassVBO(fromPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
    }
    
    func findFaces() {
        // Functions return a 'tidyUp' closure which we call to release the pixel buffer
        var facePoints : [[NSValue]] = []
        let (bigCamImg, bigTidyUp) = textureManager!.uprightPixelBufferAsCamImg()
        let (smallCamImg, smallTidyUp) = textureManager!.smallPixelBufferAsCamImg()
        if let big = bigCamImg, let small = smallCamImg {
            facePoints = faceDetector.facesPointsInBigImage(big, andSmallImage: small, withScale: Int32(scale)) as! [[NSValue]]
        }
        bigTidyUp()
        smallTidyUp()
        
        let numFaces = facePoints.count
        guard numFaces > 0 else {
            return
        }
        
        for pointArray in facePoints {
            let uvPoints = pointArray.map {
                return $0.PhiPointValue
            }
            let xyPoints = doWarp(uvPoints)
            drawBlurFace(XY: xyPoints, UV: uvPoints)
            drawClearFace(XY: xyPoints, UV: uvPoints)
            drawRightEye(XY: xyPoints, UV: uvPoints)
            drawLeftEye(XY: xyPoints, UV: uvPoints)
            drawMouth(XY: xyPoints, UV: uvPoints)
        }
    }
    
    func drawBlurFace(XY xy: [PhiPoint], UV uv: [PhiPoint]) {
        let box = textureManager!.uprightRect
        if let box = box {
            glEnable(GLenum(GL_BLEND))
            glBlendFuncSeparate(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA), GLenum(GL_ZERO), GLenum(GL_ONE))
            let (xyzSlot, uvSlot, alphaSlot, textureSlot) = shaderManager!.activatePassThroughShader()
            vertexManager!.fillFaceVertex(XY: xy, UV: uv, inBox: box, inFaceAlpha: 1.0, outFaceAlpha: 1.0, aroundEyesAlpha: 1.0, aroundMouthAlpha: 1.0)
            vertexManager!.selectFacePart(FacePart.SKIN)
            let (num, type) = vertexManager!.bindFaceVBO(withPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
            textureManager!.bindVBlurTextureToSlot(textureSlot)
            textureManager!.bindOutputTextureAsOutput()
            textureManager!.setViewPortForOutputTexture()
            glDrawElements(GLenum(GL_TRIANGLES), num, type, nil)
            vertexManager!.unbindFaceVBO(fromPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
            glDisable(GLenum(GL_BLEND))
        }
    }
    
    func drawClearFace(XY xy: [PhiPoint], UV uv: [PhiPoint]) {
        let box = textureManager!.uprightRect
        if let box = box {
            glEnable(GLenum(GL_BLEND))
            glBlendFuncSeparate(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA), GLenum(GL_ZERO), GLenum(GL_ONE))
            let (xyzSlot, uvSlot, alphaSlot, textureSlot) = shaderManager!.activatePassThroughShader()
            vertexManager!.fillFaceVertex(XY: xy, UV: uv, inBox: box, inFaceAlpha: 0.6, outFaceAlpha: 1.0, aroundEyesAlpha: 0.9, aroundMouthAlpha: 0.9)
            vertexManager!.selectFacePart(FacePart.SKIN)
            let (num, type) = vertexManager!.bindFaceVBO(withPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
            textureManager!.bindUprightTextureToSlot(textureSlot)
            textureManager!.bindOutputTextureAsOutput()
            textureManager!.setViewPortForOutputTexture()
            glDrawElements(GLenum(GL_TRIANGLES), num, type, nil)
            vertexManager!.unbindFaceVBO(fromPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
            glDisable(GLenum(GL_BLEND))
        }
    }
    
    func drawMouth(XY xy: [PhiPoint], UV uv: [PhiPoint]) {
        let box = textureManager!.uprightRect
        if let box = box {
            let (xyzSlot, uvSlot, alphaSlot, textureSlot) = shaderManager!.activatePassThroughShader()
            vertexManager!.fillFaceVertex(XY: xy, UV: uv, inBox: box)
            vertexManager!.selectFacePart(FacePart.ALL_MOUTH)
            let (num, type) = vertexManager!.bindFaceVBO(withPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
            textureManager!.bindUprightTextureToSlot(textureSlot)
            textureManager!.bindOutputTextureAsOutput()
            textureManager!.setViewPortForOutputTexture()
            glDrawElements(GLenum(GL_TRIANGLES), num, type, nil)
            vertexManager!.unbindFaceVBO(fromPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
        }
    }
    
    func drawRightEye(XY xy: [PhiPoint], UV uv: [PhiPoint]) {
        let box = textureManager!.uprightRect
        if let box = box {
            let (xyzSlot, uvSlot, alphaSlot, textureSlot) = shaderManager!.activatePassThroughShader()
            vertexManager!.fillFaceVertex(XY: xy, UV: uv, inBox: box)
            vertexManager!.selectFacePart(FacePart.RIGHT_EYE)
            let (num, type) = vertexManager!.bindFaceVBO(withPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
            textureManager!.bindUprightTextureToSlot(textureSlot)
            textureManager!.bindOutputTextureAsOutput()
            textureManager!.setViewPortForOutputTexture()
            glDrawElements(GLenum(GL_TRIANGLES), num, type, nil)
            vertexManager!.unbindFaceVBO(fromPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
        }
    }
    func drawLeftEye(XY xy: [PhiPoint], UV uv: [PhiPoint]) {
        let box = textureManager!.uprightRect
        if let box = box {
            let (xyzSlot, uvSlot, alphaSlot, textureSlot) = shaderManager!.activatePassThroughShader()
            vertexManager!.fillFaceVertex(XY: xy, UV: uv, inBox: box)
            vertexManager!.selectFacePart(FacePart.LEFT_EYE)
            let (num, type) = vertexManager!.bindFaceVBO(withPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
            textureManager!.bindUprightTextureToSlot(textureSlot)
            textureManager!.bindOutputTextureAsOutput()
            textureManager!.setViewPortForOutputTexture()
            glDrawElements(GLenum(GL_TRIANGLES), num, type, nil)
            vertexManager!.unbindFaceVBO(fromPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
        }
    }
    
    func doWarp(uv : [PhiPoint]) -> [PhiPoint] {
        return warper.doWarp(uv, warp: WarpType.SILLY)
    }
    
    func scheduleSave() {
        captureNext = true
    }
    
    func renderToScreen() {
        let (xyzSlot, uvSlot, alphaSlot, textureSlot) = shaderManager!.activatePassThroughShader()
        
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
        
        let (num, type) = vertexManager!.bindPostprocessVBO(withPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
        textureManager!.bindOutputTextureToSlot(textureSlot)
        glDrawElements(GLenum(GL_TRIANGLES), num, type, nil)
        vertexManager!.unbindPostprocessVBO(fromPositionSlot: xyzSlot, andUVSlot: uvSlot, andAlphaSlot: alphaSlot)
    }
    func render() {
        glClear(GLenum(GL_COLOR_BUFFER_BIT))
        let _pastOrientation = orientation
        orientation = UIApplication.sharedApplication().statusBarOrientation
        setupForOrientation(withScale: scale)
        preprocessRender() // Generates upright and small-upright images
        blurRender() // Render from small upright texture to hblurred texture to vlburred to output texture
        clearToOutput() // renders upright to output
        findFaces() // Finds faces and renders them to output
        renderToScreen()
        pastOrientation = _pastOrientation
        if captureNext {
            captureNext = false
            glFinish()
            textureManager!.saveOutput()
        }
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    
}