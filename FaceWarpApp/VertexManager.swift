//
//  FaceVertices.swift
//  FaceWarpApp
//
//  Created by Thomas Nickson on 01/10/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

import Foundation


// MARK: Function to make frame edges
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


// MARK: Triangles making up the various things
let ALLFACE : [GLubyte] = [ 0, 36, 17,36, 18, 17,36, 37, 18,37, 19, 18,37, 38, 19,38, 20, 19,38, 39, 20,39, 21, 20,36, 41, 37,41, 40, 37,40, 38, 37,40, 39, 38,39, 27, 21,27, 22, 21,27, 42, 22,42, 23, 22,42, 43, 23,43, 24, 23,43, 44, 24,44, 25, 24,44, 45, 25,45, 26, 25,45, 16, 26,42, 47, 43,47, 44, 43,47, 46, 44,46, 45, 44,39, 28, 27,28, 42, 27,32, 33, 30,33, 34, 30,31, 30, 32,31, 30, 29,34, 35, 30,35, 29, 30,35, 28, 29,31, 29, 28, 0,  1, 36,39, 31, 28,35, 42, 28,15, 16, 45,40, 31, 39,35, 47, 42, 1, 41, 36, 1, 40, 41,15, 45, 46,15, 46, 47,35, 15, 47, 1, 31, 40, 1,  2, 31,35, 14, 15, 2, 48, 31, 3, 48,  2, 4, 48,  3,54, 14, 35,54, 13, 14,12, 13, 54, 4,  5, 48, 5, 59, 48,11, 12, 54,55, 11, 54,10, 11, 55,56, 10, 55, 9, 10, 56, 5,  6, 59, 6, 58, 59, 6,  7, 58, 7, 57, 58, 7,  8, 57,57,  9, 56, 8,  9, 57,48, 49, 31,53, 54, 35,49, 50, 31,52, 53, 35,50, 32, 31,52, 35, 34,50, 51, 32,51, 52, 34,51, 34, 33,51, 33, 32,48, 60, 49,59, 60, 48,60, 67, 61,64, 54, 53,55, 54, 64,65, 64, 63,67, 62, 61,65, 63, 62,67, 66, 62,66, 65, 62,51, 52, 63,61, 62, 51,60, 61, 49,61, 50, 49,63, 64, 53,63, 53, 52,61, 51, 50,51, 62, 63,59, 67, 60,59, 58, 67,58, 57, 67,57, 66, 67,57, 65, 66,57, 56, 65,65, 55, 56,55, 64, 65]
let REYE : [GLubyte] = [
    42, 47, 43, 47, 44, 43, 47, 46, 44, 46, 45, 44
]
let INNERMOUTH : [GLubyte] = [
    60, 67, 61, 65, 64, 63, 67, 62, 61, 65, 63, 62, 67, 66, 62, 66, 65, 62
]
let LEYE : [GLubyte] = [
    36, 41, 37, 41, 40, 37, 40, 38, 37, 40, 39, 38
]
let NOSE : [GLubyte] = [
    32, 33, 30, 33, 34, 30, 31, 30, 32, 31, 30, 29, 34, 35, 30, 35, 29, 30, 35, 28, 29, 31, 29, 28
]
let MOUTH : [GLubyte] = [
    48, 60, 49, 59, 60, 48, 60, 67, 61, 64, 54, 53, 55, 54, 64, 65, 64, 63, 67, 62, 61, 65, 63, 62, 67, 66, 62, 66, 65, 62, 51, 52, 63, 61, 62, 51, 60, 61, 49, 61, 50, 49, 63, 64, 53, 63, 53, 52, 61, 51, 50, 51, 62, 63, 59, 67, 60, 59, 58, 67, 58, 57, 67, 57, 66, 67, 57, 65, 66, 57, 56, 65, 65, 55, 56, 55, 64, 65
]
let SKIN : [GLubyte] = [
0, 36, 17, 36, 18, 17, 36, 37, 18, 37, 19, 18, 37, 38, 19, 38, 20, 19, 38, 39, 20, 39, 21, 20, 39, 27, 21, 27, 22, 21, 27, 42, 22, 42, 23, 22, 42, 43, 23, 43, 24, 23, 43, 44, 24, 44, 25, 24, 44, 45, 25, 45, 26, 25, 45, 16, 26, 39, 28, 27, 28, 42, 27, 32, 33, 30, 33, 34, 30, 31, 30, 32, 31, 30, 29, 34, 35, 30, 35, 29, 30, 35, 28, 29, 31, 29, 28, 0, 1, 36, 39, 31, 28, 35, 42, 28, 15, 16, 45, 40, 31, 39, 35, 47, 42, 1, 41, 36, 1, 40, 41, 15, 45, 46, 15, 46, 47, 35, 15, 47, 1, 31, 40, 1, 2, 31, 35, 14, 15, 2, 48, 31, 3, 48, 2, 4, 48, 3, 54, 14, 35, 54, 13, 14, 12, 13, 54, 4, 5, 48, 5, 59, 48, 11, 12, 54, 55, 11, 54, 10, 11, 55, 56, 10, 55, 9, 10, 56, 5, 6, 59, 6, 58, 59, 6, 7, 58, 7, 57, 58, 7, 8, 57, 57, 9, 56, 8, 9, 57, 48, 49, 31, 53, 54, 35, 49, 50, 31, 52, 53, 35, 50, 32, 31, 52, 35, 34, 50, 51, 32, 51, 52, 34, 51, 34, 33, 51, 33, 32
]


enum FacePart {
    case ALL, RIGHT_EYE, LEFT_EYE, NOSE, ALL_MOUTH, INNER_MOUTH, SKIN
}

enum ImgFlip {
    case NONE, HORIZONTAL, VERTICAL, BOTH
}

let squareIndices: [GLubyte] = [
    1, 2, 0,
    0, 2, 3,
]

let mouth_indices : [GLubyte] = [ // To draw to 50x20 texture
    0, 1, 2,
    6, 7, 0,
    6, 0, 2,
    2, 4, 6,
    1, 4, 3,
    6, 5, 4
]
//
//let inner_mouth_indices : [GLubyte] = [
//    0, 7, 1,
//    5, 4, 3,
//    7, 2, 1,
//    5, 3, 2,
//    7, 6, 2,
//    6, 5, 2
//]

let predrawIndices : [GLubyte] = [ 0, 12,  1, 12, 13,  1,  1, 13, 12,  1,  2, 13, 13,  3,  2, 13, 14,
    3, 14, 15,  3, 15,  4,  3, 16, 15,  5, 16,  6,  5, 17,  7, 16, 17,
    18,  9,  9,  8, 17,  9, 17, 18,  7,  8, 17, 10,  9, 19, 11, 10, 19,
    11, 19, 12, 11, 12,  0, 19, 18, 12, 12, 14, 13, 12, 18, 14, 18, 16,
    14, 14, 16, 15, 18, 17, 16]

let predrawXYZ : [ImagePosition] = [(-1, 0, 0),(-1, 0.6, 0),(-0.6, 1, 0),(0, 1, 0),(0.6, 1, 0),(1, 0.6, 0),(1, 0, 0),(1, -0.6, 0),(0.6, -1, 0),(0, -1, 0),(-0.6, -1, 0),(-1, -0.6, 0),(-0.75, 0.0, 0),(-0.75, 0.75, 0),(0, 0.75, 0),(0.75, 0.75, 0),(0.75, 0.0, 0),(0.75, -0.75, 0),(0, -0.75, 0),(-0.75, -0.75, 0)]

class VertexManager {
    
    var preprocessAO : GLuint = GLuint()  // Used to rotate the input video to the correct orientation for dlib
    var passAO : GLuint = GLuint()        // Used for pass-through draws - shrinking textures etc
    var faceAO : GLuint = GLuint()        // Used for drawing face regions
    var postprocessAO : GLuint = GLuint() // Used to rotate the output to the correct orientation for display or recording
    var mouthAO : GLuint = GLuint()
    var brightermouthAO : GLuint = GLuint()
    
    var passPositionBuffer : GLuint = GLuint()
    var passIndexBuffer : GLuint = GLuint()
    
    var preprocessPositionBuffer : GLuint = GLuint()
    var preprocessIndexBuffer : GLuint = GLuint()
    
    var postprocessPositionBuffer : GLuint = GLuint()
    var postprocessIndexBuffer : GLuint = GLuint()
    
    var mouthPositionBuffer : GLuint = GLuint()
    var mouthIndexBuffer : GLuint = GLuint()
    
    var brightermouthPositionBuffer : GLuint = GLuint()
    var brightermouthIndexBuffer : GLuint = GLuint()
    
    var facePositionBuffer : GLuint = GLuint()
    var faceIndexBuffer : GLuint = GLuint()
    var numFaceIdx = 0
    
    init() {
        setupPassVBO()
        setupPostprocessVBO()
        setupPreprocessVBO()
        setupFaceVBO()
        setupPredrawMouthVBO()
        setupBrighterMouthVBO()
    }
    
    func setupPassVBO() {
        glGenVertexArraysOES(1, &passAO);
        glGenBuffers(1, &passPositionBuffer)
        glGenBuffers(1, &passIndexBuffer)
        
        let vertices = makeSquareVertices()
        
        glBindVertexArrayOES(passAO);
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), passPositionBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), vertices.size(), vertices, GLenum(GL_STATIC_DRAW))
    
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), passIndexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), squareIndices.size(), squareIndices, GLenum(GL_STATIC_DRAW))
        
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
    }
    
    func bindPassVBO(withPositionSlot positionSlot: GLuint, andUVSlot uvSlot : GLuint, andAlphaSlot alphaSlot : GLuint) -> (GLint, GLenum) {
        glBindVertexArrayOES(passAO);
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), passPositionBuffer)
        glEnableVertexAttribArray(positionSlot)
        glVertexAttribPointer(positionSlot, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), nil)
        glEnableVertexAttribArray(uvSlot)
        glVertexAttribPointer(uvSlot, 2, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), UnsafePointer(bitPattern: sizeof(ImagePosition)))
        glEnableVertexAttribArray(alphaSlot)
        glVertexAttribPointer(alphaSlot, 1, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), UnsafePointer(bitPattern: sizeof(TexturePosition) + sizeof(ImagePosition)))
        
        
        return (GLint(squareIndices.count), GLenum(GL_UNSIGNED_BYTE))
    }
    
    func unbindPassVBO(fromPositionSlot positionSlot: GLuint, andUVSlot uvSlot : GLuint, andAlphaSlot alphaSlot : GLuint) {
        glDisableVertexAttribArray(positionSlot)
        glDisableVertexAttribArray(uvSlot)
        glDisableVertexAttribArray(alphaSlot)
        
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
    }
    
    func setupPreprocessVBO() {
        glGenVertexArraysOES(1, &preprocessAO);
        glGenBuffers(1, &preprocessPositionBuffer)
        glGenBuffers(1, &preprocessIndexBuffer)
    }
    
    func fillPreprocessVBO(forFlip flip : ImgFlip = .NONE, andRotate90 rotate : Bool = false) {
        let vertices = makeSquareVertices(withFlip: flip, andRotate90: rotate)
        
        glBindVertexArrayOES(preprocessAO);
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), preprocessPositionBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), vertices.size(), vertices, GLenum(GL_STATIC_DRAW))
        
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), preprocessIndexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), squareIndices.size(), squareIndices, GLenum(GL_STATIC_DRAW))
        
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0);
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0);
    }
    
    func bindPreprocessVBO(withPositionSlot positionSlot: GLuint, andUVSlot uvSlot : GLuint, andAlphaSlot alphaSlot : GLuint) -> (GLint, GLenum) {
        glBindVertexArrayOES(preprocessAO);
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), preprocessPositionBuffer)
        glEnableVertexAttribArray(positionSlot)
        glVertexAttribPointer(positionSlot, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), nil)

        glEnableVertexAttribArray(uvSlot)
        glVertexAttribPointer(uvSlot, 2, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), UnsafePointer(bitPattern: sizeof(ImagePosition)))
        
        glEnableVertexAttribArray(alphaSlot)
        glVertexAttribPointer(alphaSlot, 1, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), UnsafePointer(bitPattern: sizeof(TexturePosition) + sizeof(ImagePosition)))
        

        return (GLint(squareIndices.count), GLenum(GL_UNSIGNED_BYTE))
    }
    
    func unbindPreprocessVBO(fromPositionSlot positionSlot: GLuint, andUVSlot uvSlot : GLuint, andAlphaSlot alphaSlot : GLuint) {
        glDisableVertexAttribArray(positionSlot)
        glDisableVertexAttribArray(uvSlot)
        glDisableVertexAttribArray(alphaSlot)
        
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
    }
    
    func setupPostprocessVBO() {
        glGenVertexArraysOES(1, &postprocessAO);
        glGenBuffers(1, &postprocessPositionBuffer)
        glGenBuffers(1, &postprocessIndexBuffer)
    }
    
    func fillPostprocessVBO(forFlip flip : ImgFlip = .NONE, andRotate90 rotate : Bool = false) {
        let vertices = makeSquareVertices(withFlip: flip, andRotate90: rotate)
        
        glBindVertexArrayOES(postprocessAO);
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), postprocessPositionBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), vertices.size(), vertices, GLenum(GL_STATIC_DRAW))
        
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), postprocessIndexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), squareIndices.size(), squareIndices, GLenum(GL_STATIC_DRAW))
        
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
    }
    
    func bindPostprocessVBO(withPositionSlot positionSlot: GLuint, andUVSlot uvSlot : GLuint, andAlphaSlot alphaSlot : GLuint) -> (GLint, GLenum) {
        glBindVertexArrayOES(postprocessAO);
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), postprocessPositionBuffer)
        glEnableVertexAttribArray(positionSlot)
        glVertexAttribPointer(positionSlot, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), nil)
        glEnableVertexAttribArray(uvSlot)
        glVertexAttribPointer(uvSlot, 2, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), UnsafePointer(bitPattern: sizeof(ImagePosition)))
        glEnableVertexAttribArray(alphaSlot)
        glVertexAttribPointer(alphaSlot, 1, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), UnsafePointer(bitPattern: sizeof(TexturePosition) + sizeof(ImagePosition)))
        
        return (GLint(squareIndices.count), GLenum(GL_UNSIGNED_BYTE))
    }
    
    func unbindPostprocessVBO(fromPositionSlot positionSlot: GLuint, andUVSlot uvSlot : GLuint, andAlphaSlot alphaSlot : GLuint) {
        glDisableVertexAttribArray(positionSlot)
        glDisableVertexAttribArray(uvSlot)
        glDisableVertexAttribArray(alphaSlot)
        
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
    }

    func UV(uv : (GLfloat, GLfloat), ForFlip flip : ImgFlip = .NONE, andRotate90 rotate : Bool = false) -> (GLfloat, GLfloat) {
        let rot_u = rotate ? uv.1 : uv.0
        let rot_v = rotate ? uv.0 : uv.1
        switch flip {
        case .NONE:
            return (rot_u, rot_v)
        case .HORIZONTAL:
            return (1 - rot_u, rot_v)
        case .VERTICAL:
            return (rot_u, 1 - rot_v)
        case .BOTH:
            return (1 - rot_u, 1 - rot_v)
        }
    }

    func makeSquareVertices(withFlip flip : ImgFlip = .NONE, andRotate90 rotate : Bool = false) -> [Coordinate] {
        let vertices = [
            Coordinate(xyz : (-1, -1, 0), uv : UV((0, 0), ForFlip: flip, andRotate90: rotate), alpha: 1),
            Coordinate(xyz : (-1,  1, 0), uv : UV((0, 1), ForFlip: flip, andRotate90: rotate), alpha: 1),
            Coordinate(xyz : ( 1,  1, 0), uv : UV((1, 1), ForFlip: flip, andRotate90: rotate), alpha: 1),
            Coordinate(xyz : ( 1, -1, 0), uv : UV((1, 0), ForFlip: flip, andRotate90: rotate), alpha: 1),
        ]
        return vertices
    }
    
    
    // MARK: Management of face vertex buffer object
    func setupFaceVBO() {
        glGenVertexArraysOES(1, &faceAO);
        glGenBuffers(1, &facePositionBuffer)
        glGenBuffers(1, &faceIndexBuffer)
    }
    
    func fillFaceVertex(XY xyPoints : [PhiPoint], UV uvPoints : [PhiPoint], inBox box: CGRect,
                        inFaceAlpha alphaIn : Float = 1.0, outFaceAlpha alphaOut : Float = 1.0,
                        aroundEyesAlpha eyeAlpha : Float = 1.0, aroundMouthAlpha mouthAlpha : Float = 1.0) {
        let width = GLfloat(box.width)
        let height = GLfloat(box.height)
        var faceVertices : [Coordinate] = []
        for (idx, (xy, uv)) in zip(xyPoints, uvPoints).enumerate() {
            let x = 2 * GLfloat(xy.x) / width - 1
            let y = 2 * GLfloat(xy.y) / height - 1
            let u = GLfloat(uv.x) / width
            let v = GLfloat(uv.y) / height
            var alpha : Float
            if idx < 27 {
                alpha = alphaOut
            } else if idx < 36 {
                alpha = alphaIn
            } else if idx < 46 {
                alpha = eyeAlpha
            } else {
                alpha = mouthAlpha
            }
            faceVertices.append(
                Coordinate(xyz: (x, y, 0), uv: (u, v), alpha: GLfloat(alpha))
            )
        }
        
        glBindVertexArrayOES(faceAO);
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), facePositionBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), faceVertices.size(), faceVertices, GLenum(GL_STATIC_DRAW))
        
        glBindVertexArray(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
    }
    
    func selectFacePart(part : FacePart) {
        glBindVertexArrayOES(faceAO);
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), faceIndexBuffer)
        var num = 0
        
        switch part {
        case .ALL:
            glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), ALLFACE.size(), ALLFACE, GLenum(GL_STATIC_DRAW))
            num = ALLFACE.count
        case .ALL_MOUTH:
            glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), MOUTH.size(), MOUTH, GLenum(GL_STATIC_DRAW))
            num = MOUTH.count
        case .INNER_MOUTH:
            glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), INNERMOUTH.size(), INNERMOUTH, GLenum(GL_STATIC_DRAW))
            num = INNERMOUTH.count
        case .LEFT_EYE:
            glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), LEYE.size(), LEYE, GLenum(GL_STATIC_DRAW))
            num = LEYE.count
        case .NOSE:
            glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), NOSE.size(), NOSE, GLenum(GL_STATIC_DRAW))
            num = NOSE.count
        case .RIGHT_EYE:
            glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), REYE.size(), REYE, GLenum(GL_STATIC_DRAW))
            num = REYE.count
        case .SKIN:
            glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), SKIN.size(), SKIN, GLenum(GL_STATIC_DRAW))
            num = SKIN.count
        }
        glBindVertexArray(0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
        numFaceIdx = num
    }
    
    func bindFaceVBO(withPositionSlot positionSlot: GLuint, andUVSlot uvSlot : GLuint, andAlphaSlot alphaSlot : GLuint) -> (GLint, GLenum) {
        glBindVertexArrayOES(faceAO);
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), facePositionBuffer)
        glEnableVertexAttribArray(positionSlot)
        glVertexAttribPointer(positionSlot, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), nil)
        glEnableVertexAttribArray(uvSlot)
        glVertexAttribPointer(uvSlot, 2, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), UnsafePointer(bitPattern: sizeof(ImagePosition)))
        glEnableVertexAttribArray(alphaSlot)
        glVertexAttribPointer(alphaSlot, 1, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), UnsafePointer(bitPattern: sizeof(TexturePosition) + sizeof(ImagePosition)))
        
        return (GLint(numFaceIdx), GLenum(GL_UNSIGNED_BYTE))
        
    }
    
    func unbindFaceVBO(fromPositionSlot positionSlot: GLuint, andUVSlot uvSlot : GLuint, andAlphaSlot alphaSlot : GLuint) {
        glDisableVertexAttribArray(positionSlot)
        glDisableVertexAttribArray(uvSlot)
        glDisableVertexAttribArray(alphaSlot)
        
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
    }
    
    // MARK: Fill up mouth vertices to draw to the 50x20 image
    func setupPredrawMouthVBO() {
        glGenVertexArraysOES(1, &mouthAO);
        glGenBuffers(1, &mouthPositionBuffer)
        glGenBuffers(1, &mouthIndexBuffer)
    }
    
    func fillPredrawMouthVBO(UV uv: [PhiPoint], inBox box: CGRect) {
        
        glBindVertexArrayOES(mouthAO);
        
        

        let mouth_vertices = zip(uv, predrawXYZ).map { (point, xyz) -> Coordinate in
            let unorm = GLfloat(point.x) / GLfloat(box.width)
            let vnorm = GLfloat(point.y) / GLfloat(box.height)
            return Coordinate(xyz: xyz, uv: (unorm, vnorm), alpha: 1.0)
        }

        glBindBuffer(GLenum(GL_ARRAY_BUFFER), mouthPositionBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), mouth_vertices.size(), mouth_vertices, GLenum(GL_STATIC_DRAW))
        
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), mouthIndexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), predrawIndices.size(), predrawIndices, GLenum(GL_STATIC_DRAW))
        
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
    }
    
    func bindPredrawMouthVBO(withPositionSlot positionSlot: GLuint, andUVSlot uvSlot : GLuint, andAlphaSlot alphaSlot : GLuint) -> (GLint, GLenum) {
        glBindVertexArrayOES(mouthAO);
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), mouthPositionBuffer)
        glEnableVertexAttribArray(positionSlot)
        glVertexAttribPointer(positionSlot, 3, GLenum(GL_FLOAT),
            GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), nil)
        glEnableVertexAttribArray(uvSlot)
        glVertexAttribPointer(uvSlot, 2, GLenum(GL_FLOAT),
            GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), UnsafePointer(bitPattern: sizeof(ImagePosition)))
        glEnableVertexAttribArray(alphaSlot)
        glVertexAttribPointer(alphaSlot, 1, GLenum(GL_FLOAT),
            GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), UnsafePointer(bitPattern: sizeof(TexturePosition) + sizeof(ImagePosition)))
        return (GLint(predrawIndices.count), GLenum(GL_UNSIGNED_BYTE))
    }
    
    func unbindPredrawMouthVBO(fromPositionSlot positionSlot: GLuint, andUVSlot uvSlot : GLuint, andAlphaSlot alphaSlot : GLuint) {
        glDisableVertexAttribArray(positionSlot)
        glDisableVertexAttribArray(uvSlot)
        glDisableVertexAttribArray(alphaSlot)
        
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
    }
    
    // MARK: Fill up mouth vertices to draw to the final image with brightening
    func setupBrighterMouthVBO() {
        glGenVertexArraysOES(1, &brightermouthAO);
        glGenBuffers(1, &brightermouthPositionBuffer)
        glGenBuffers(1, &brightermouthIndexBuffer)
    }
    
    func fillBrighterMouthVBO(UV uv: [PhiPoint], XY xy : [PhiPoint], inBox box: CGRect, withBrightness brightenFactor : GLfloat) {
        
        glBindVertexArrayOES(brightermouthAO);

        let mouth_vertices = zip(uv, xy).enumerate().map { (idx, points) -> Coordinate in
            let uv_el = points.0
            let xy_el = points.1
            let unorm = GLfloat(uv_el.x) / GLfloat(box.width)
            let vnorm = GLfloat(uv_el.y) / GLfloat(box.height)
            let xnorm = GLfloat(xy_el.x) / GLfloat(box.width) * 2 - 1
            let ynorm = GLfloat(xy_el.y) / GLfloat(box.height) * 2 - 1
            let brighten = idx < 12 ? GLfloat(0.0) : brightenFactor
            return Coordinate(xyz: (xnorm, ynorm, 0), uv: (unorm, vnorm), alpha: brighten)
        }
        
        let these_mouth_indices = MOUTH.map{$0 - MOUTH.minElement()!}
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), brightermouthPositionBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), mouth_vertices.size(), mouth_vertices, GLenum(GL_STATIC_DRAW))
        
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), brightermouthIndexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), these_mouth_indices.size(), these_mouth_indices, GLenum(GL_STATIC_DRAW))
        
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
    }
    
    func bindBrighterMouthVBO(withPositionSlot positionSlot: GLuint, andUVSlot uvSlot : GLuint, andBrightenSlot brightenSlot : GLuint) -> (GLint, GLenum) {
        glBindVertexArrayOES(brightermouthAO);
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), brightermouthPositionBuffer)
        glEnableVertexAttribArray(positionSlot)
        glVertexAttribPointer(positionSlot, 3, GLenum(GL_FLOAT),
            GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), nil)
        glEnableVertexAttribArray(uvSlot)
        glVertexAttribPointer(uvSlot, 2, GLenum(GL_FLOAT),
            GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), UnsafePointer(bitPattern: sizeof(ImagePosition)))
        glEnableVertexAttribArray(brightenSlot)
        glVertexAttribPointer(brightenSlot, 1, GLenum(GL_FLOAT),
            GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), UnsafePointer(bitPattern: sizeof(TexturePosition) + sizeof(ImagePosition)))
        
        return (GLint(MOUTH.count), GLenum(GL_UNSIGNED_BYTE))
    }
    
    func unbindBrighterMouthVBO(fromPositionSlot positionSlot: GLuint, andUVSlot uvSlot : GLuint, andBrightenSlot brightenSlot : GLuint) {
        glDisableVertexAttribArray(positionSlot)
        glDisableVertexAttribArray(uvSlot)
        glDisableVertexAttribArray(brightenSlot)
        
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
    }
}