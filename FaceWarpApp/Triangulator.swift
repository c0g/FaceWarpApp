//
//  Triangulator.swift
//  FaceWarpApp
//
//  Created by Thomas Nickson on 25/09/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

import Foundation

//WORD *BuildTriangleIndexList (void *pointList, float factor, int numberOfInputPoints, int numDimensions, int clockwise, int *numTriangleVertices )
class Triangulator {
    func triang() {
        var numTriangleVertices : Int32 = 0
        var data : [Float] = []
        let rawAns = BuildTriangleIndexList(&data, 1.0, Int32(1), Int32(1), Int32(1), &numTriangleVertices)
        let floatAns = UnsafeMutablePointer<Float>(rawAns)
        // Copy raw ans into nice, safe, swifty world
        var indices : [Float] = []
        for idx in 0..<numTriangleVertices {
            indices.append(floatAns[Int(idx)])
        }
        free(rawAns)
    }
}