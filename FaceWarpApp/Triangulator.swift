//
//  Triangulator.swift
//  FaceWarpApp
//
//  Created by Thomas Nickson on 26/09/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

import Foundation


func wrapIt() {
    var edges : [Float] = [1, 2, 3]
    var landmarks : [Float] = [1, 2, 3]
    let numFaces : Int32 = 2
    let numEdges : Int32 = 2
    var tris : Int32 = 0
    let ans = tidyIndices(&edges, Int32(2), &landmarks, Int32(2), &tris)
    
    var safeAns : [Int] = []
    for idx in 0..<tris {
        safeAns.append(Int(ans[Int(idx)]))
    }

    free(ans)
}