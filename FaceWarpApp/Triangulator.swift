//
//  Triangulator.swift
//  FaceWarpApp
//
//  Created by Thomas Nickson on 26/09/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

import Foundation


func tidyIndices(edgesAndLandmarks : [CGPoint], numEdges : Int, numFaces : Int) -> [PhiTriangle] {
    var edgesAndLandmarksMutable = edgesAndLandmarks
    var tris : Int32 = 0
    let ans = unsafeTidyIndices(&edgesAndLandmarksMutable, Int32(numEdges), Int32(numFaces), &tris)
    var safeAns : [PhiTriangle] = []
    for idx in 0..<Int(tris) {
        safeAns.append(ans[idx])
    }
    free(ans)
    return safeAns
}