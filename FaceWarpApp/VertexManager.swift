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

enum WhatToDraw {
    case ALL, RIGHT_EYE, LEFT_EYE, NOSE, ALL_MOUTH, INNER_MOUTH
}

enum ImgFlip {
    case NONE, HORIZONTAL, VERTICAL, BOTH
}

let squareIndices: [GLubyte] = [
    1, 2, 0,
    0, 2, 3,
]

class VertexManager {
    
    var preprocessAO : GLuint = GLuint()  // Used to rotate the input video to the correct orientation for dlib
    var passAO : GLuint = GLuint()        // Used for pass-through draws - shrinking textures etc
    var faceAO : GLuint = GLuint()        // Used for drawing face regions
    var postprocessAO : GLuint = GLuint() // Used to rotate the output to the correct orientation for display or recording
    
    var passPositionBuffer : GLuint = GLuint()
    var passIndexBuffer : GLuint = GLuint()
    
    var preprocessPositionBuffer : GLuint = GLuint()
    var preprocessIndexBuffer : GLuint = GLuint()
    
    var postprocessPositionBuffer : GLuint = GLuint()
    var postprocessIndexBuffer : GLuint = GLuint()
    
    init() {
        setupPassVBO()
        setupPostprocessVBO()
        setupPreprocessVBO()
    }
    
    func setupPassVBO() {
        glGenVertexArraysOES(1, &passAO);
        print(passAO)
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
    
    func bindPassVBO(withPositionSlot positionSlot: GLuint, andUVSlot uvSlot : GLuint) -> (GLint, GLenum) {
        glBindVertexArrayOES(passAO);
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), passPositionBuffer)
        glEnableVertexAttribArray(positionSlot)
        glVertexAttribPointer(positionSlot, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), nil)
        glEnableVertexAttribArray(uvSlot)
        glVertexAttribPointer(uvSlot, 2, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), UnsafePointer(bitPattern: sizeof(ImagePosition)))
        
        return (GLint(squareIndices.count), GLenum(GL_UNSIGNED_BYTE))
    }
    
    func unbindPassVBO(fromPositionSlot positionSlot: GLuint, andUVSlot uvSlot : GLuint) {
        glDisableVertexAttribArray(positionSlot)
        glDisableVertexAttribArray(uvSlot)
        
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
    }
    
    func setupPreprocessVBO() {
        glGenVertexArraysOES(1, &preprocessAO);
        print(preprocessAO)
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
    
    func bindPreprocessVBO(withPositionSlot positionSlot: GLuint, andUVSlot uvSlot : GLuint) -> (GLint, GLenum) {
        glBindVertexArrayOES(preprocessAO);
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), preprocessPositionBuffer)
        glEnableVertexAttribArray(positionSlot)
        glVertexAttribPointer(positionSlot, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), nil)

        glEnableVertexAttribArray(uvSlot)
        glVertexAttribPointer(uvSlot, 2, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), UnsafePointer(bitPattern: sizeof(ImagePosition)))

        return (GLint(squareIndices.count), GLenum(GL_UNSIGNED_BYTE))
    }
    
    func unbindPreprocessVBO(fromPositionSlot positionSlot: GLuint, andUVSlot uvSlot : GLuint) {
        glDisableVertexAttribArray(positionSlot)
        glDisableVertexAttribArray(uvSlot)
        
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
    }
    
    func setupPostprocessVBO() {
        glGenVertexArraysOES(1, &postprocessAO);
        print(postprocessAO)
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
    
    func bindPostprocessVBO(withPositionSlot positionSlot: GLuint, andUVSlot uvSlot : GLuint) -> (GLint, GLenum) {
        glBindVertexArrayOES(postprocessAO);
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), postprocessPositionBuffer)
        glEnableVertexAttribArray(positionSlot)
        glVertexAttribPointer(positionSlot, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), nil)
        glEnableVertexAttribArray(uvSlot)
        glVertexAttribPointer(uvSlot, 2, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), UnsafePointer(bitPattern: sizeof(ImagePosition)))
        
        
        return (GLint(squareIndices.count), GLenum(GL_UNSIGNED_BYTE))
    }
    
    func unbindPostprocessVBO(fromPositionSlot positionSlot: GLuint, andUVSlot uvSlot : GLuint) {
        glDisableVertexAttribArray(positionSlot)
        glDisableVertexAttribArray(uvSlot)
        
        
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
            Coordinate(xyz : (-1, -1, 0), uv : UV((0, 0), ForFlip: flip, andRotate90: rotate)),
            Coordinate(xyz : (-1,  1, 0), uv : UV((0, 1), ForFlip: flip, andRotate90: rotate)),
            Coordinate(xyz : ( 1,  1, 0), uv : UV((1, 1), ForFlip: flip, andRotate90: rotate)),
            Coordinate(xyz : ( 1, -1, 0), uv : UV((1, 0), ForFlip: flip, andRotate90: rotate)),
        ]
        return vertices
    }
    
    
    func loadFacePart(toDraw : WhatToDraw, withXY xy_v: [PhiPoint], andUV uv_v: [PhiPoint]) -> ([Coordinate], [GLubyte]) {
        var vertices : [Coordinate] = []
        var indices : [GLubyte]
        switch toDraw {
        case .ALL:
            indices = ALLFACE
        case .RIGHT_EYE:
            indices = REYE
        case .LEFT_EYE:
            indices = LEYE
        case .ALL_MOUTH:
            indices = MOUTH
        case .INNER_MOUTH:
            indices = INNERMOUTH
        case .NOSE:
            indices = NOSE
        }
        return (vertices, indices)
    }
}

//
//func makeGLDataWithIndices(indices : [PhiTriangle], andVertices vertices : [PhiPoint]) -> ([GLushort], [Coordinate]) {
//    var glindices : [GLushort] = []
//    for tri in indices {
//        glindices.append(GLushort(tri.p0))
//        glindices.append(GLushort(tri.p1))
//        glindices.append(GLushort(tri.p2))
//    }
//    
//    var glvertices : [Coordinate] = []
//    
//    // The first group of the vertices are faces, and we want to apply the warp
//    for faceidx in 0..<numfaces {
//        let offset = faceidx * 68
//        let slice : [PhiPoint] = Array(vertices[offset..<offset + 68])
//        let tmpArray = warper.doWarp(slice, warp: .SILLY)
//        for pidx in 0..<68 {
//            let warped_point = tmpArray[pidx]
//            let unwarped_point = slice[pidx]
//            let xn_w = GLfloat(warped_point.x) / 1280.0
//            let yn_w = GLfloat(warped_point.y) / 720.0
//            let xn_u = GLfloat(unwarped_point.x) / 1280.0
//            let yn_u = GLfloat(unwarped_point.y) / 720.0
//            let u = GLfloat(xn_u)
//            let v = GLfloat(1 - yn_u)
//            let x = GLfloat(2 * xn_w - 1)
//            let y = GLfloat(2 * yn_w - 1)
//            let z = GLfloat(0)
//            glvertices.append(Coordinate(xyz: (x, y, z), uv: (u, v)))
//        }
//    }
//    for pidx in numfaces * 68..<vertices.count {
//        let point = vertices[pidx]
//        let xn = GLfloat(point.x) / 1280.0
//        let yn = GLfloat(point.y) / 720.0
//        let u = GLfloat(xn)
//        let v = GLfloat(1 - yn)
//        let x = GLfloat(2 * xn - 1)
//        let y = GLfloat(2 * yn - 1)
//        let z = GLfloat(0)
//        glvertices.append(Coordinate(xyz: (x, y, z), uv: (u, v)))
//    }
//    return (glindices, glvertices)
//}
//
//func makeTriangulation(rawFacePoints : [[NSValue]]) -> ([PhiTriangle], [PhiPoint]) {
//    var allPoints : [PhiPoint] = []
//    for points in rawFacePoints {
//        allPoints.appendContentsOf(points.map {$0.PhiPointValue})
//    }
//    allPoints.appendContentsOf(edges)
//    let triangulation = tidyIndices(allPoints, numEdges: edges.count, numFaces: rawFacePoints.count)
//    return (triangulation, allPoints)
//}
//
//func setFaceVertices() {
//    if faceVertices.count > 0 {
//        //            print("Binding \(faceVertices.count) face vertices and \(currentIndices.count) indices")
//        glBindVertexArrayOES(VFaceAO);
//        
//        glBindBuffer(GLenum(GL_ARRAY_BUFFER), facePositionBuffer)
//        glBufferData(GLenum(GL_ARRAY_BUFFER), faceVertices.size(), faceVertices, GLenum(GL_STREAM_DRAW))
//        glEnableVertexAttribArray(positionSlot)
//        glVertexAttribPointer(positionSlot, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), nil)
//        
//        glBindBuffer(GLenum(GL_ARRAY_BUFFER), faceUvBuffer)
//        glBufferData(GLenum(GL_ARRAY_BUFFER), faceVertices.size(), faceVertices, GLenum(GL_STREAM_DRAW))
//        glEnableVertexAttribArray(uvSlot)
//        glVertexAttribPointer(uvSlot, 2, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), UnsafePointer(bitPattern: sizeof(ImagePosition)))
//        
//        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), faceIndexBuffer)
//        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), currentIndices.size(), currentIndices, GLenum(GL_STREAM_DRAW))
//        
//        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
//        glBindVertexArrayOES(0)
//    }
//}
//
//
//// Setup Vertex Buffer Objects
//func setupVBOs() {
//    glGenVertexArraysOES(1, &VAO);
//    glBindVertexArrayOES(VAO);
//    
//    glGenBuffers(1, &positionBuffer)
//    glBindBuffer(GLenum(GL_ARRAY_BUFFER), positionBuffer)
//    glBufferData(GLenum(GL_ARRAY_BUFFER), Vertices.size(), Vertices, GLenum(GL_STATIC_DRAW))
//    
//    glEnableVertexAttribArray(positionSlot)
//    glVertexAttribPointer(positionSlot, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), nil)
//    
//    glGenBuffers(1, &uvBuffer)
//    glBindBuffer(GLenum(GL_ARRAY_BUFFER), uvBuffer)
//    glBufferData(GLenum(GL_ARRAY_BUFFER), Vertices.size(), Vertices, GLenum(GL_STATIC_DRAW))
//    
//    glEnableVertexAttribArray(uvSlot)
//    glVertexAttribPointer(uvSlot, 2, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(Coordinate)), UnsafePointer(bitPattern: sizeof(ImagePosition)))
//    
//    glGenBuffers(1, &indexBuffer)
//    glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
//    glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), Indices.size(), Indices, GLenum(GL_STATIC_DRAW))
//    
//    glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
//    glBindVertexArrayOES(0)
//}
//
//
//// Setup Vertex Buffer Objects
//func setupFaceIndices() {
//    glGenVertexArraysOES(1, &VFaceAO);
//    glBindVertexArrayOES(VFaceAO);
//    
//    glGenBuffers(1, &facePositionBuffer)
//    glGenBuffers(1, &faceUvBuffer)
//    glGenBuffers(1, &faceIndexBuffer)
//    
//    glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
//    glBindVertexArrayOES(0)
//}
