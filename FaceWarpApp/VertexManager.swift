//
//  FaceVertices.swift
//  FaceWarpApp
//
//  Created by Thomas Nickson on 01/10/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

import Foundation



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

class VertexManager {
    
    var preprocessAO : GLuint = GLuint()  // Used to rotate the input video to the correct orientation for dlib
    var passAO : GLuint = GLuint()        // Used for pass-through draws - shrinking textures etc
    var faceAO : GLuint = GLuint()        // Used for drawing face regions
    var postprocessAO : GLuint = GLuint() // Used to rotate the output to the correct orientation for display or recording
    
    func UV(uv : (GLfloat, GLfloat), ForFlip flip : ImgFlip = .NONE, AndRotate90 rotate : Bool = false) -> (GLfloat, GLfloat) {
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
    
    func makeSquareVertices(withFlip flip : ImgFlip = .NONE, andRotate90 rotate : Bool = false) -> ([Coordinate],[GLubyte]) {
        let vertices = [
            Coordinate(xyz : (-1, -1, 0), uv : UV((0, 0), ForFlip: flip, AndRotate90: rotate)),
            Coordinate(xyz : (-1,  1, 0), uv : UV((0, 1), ForFlip: flip, AndRotate90: rotate)),
            Coordinate(xyz : ( 1,  1, 0), uv : UV((1, 1), ForFlip: flip, AndRotate90: rotate)),
            Coordinate(xyz : ( 1, -1, 0), uv : UV((1, 0), ForFlip: flip, AndRotate90: rotate)),
        ]
        
        let indices: [GLubyte] = [
            1, 2, 0,
            0, 2, 3,
        ]
        return (vertices, indices)
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