//
//  Warpnormalise.swift
//  FaceWarpApp
//
//  Created by Thomas Gunter on 9/26/15.
//  Copyright © 2015 Phi Research. All rights reserved.
//

import Foundation

func getNormalisedWarp( landmarks : [Double], face_flat_warp : [Double]) -> [Double]{
//    var landmarks : [Int32] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68];
//    var face_flat_warp : [Int32] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68];
    var landmarks32 = landmarks.map({Double($0)})
    var face_flat_warp32 = face_flat_warp.map({Double($0)})
    let ans = return_adjusted_warp(&landmarks32, &face_flat_warp32);
    var safeAns : [Double] = [];
    for idx in 0..<landmarks.count {
        safeAns.append(Double(ans[Int(idx)]))
    }
    
    free(ans)
    
    return safeAns
}