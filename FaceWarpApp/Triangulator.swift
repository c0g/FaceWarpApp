//
//  Triangulator.swift
//  FaceWarpApp
//
//  Created by Thomas Nickson on 26/09/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

import Foundation


func tidyIndices(var edgesAndLandmarks : [PhiPoint], numEdges : Int, numFaces : Int) -> [PhiTriangle] {
    var tris : Int32 = 0
    let ans = triangulate_wrapper(&edgesAndLandmarks, Int32(numEdges), Int32(numFaces), &tris)
    var safeAns : [PhiTriangle] = []
    for idx in 0..<Int(tris) {
        safeAns.append(ans[idx])
    }
    free(ans) 
    return safeAns
}