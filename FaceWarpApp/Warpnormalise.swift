//
//  Warpnormalise.swift
//  FaceWarpApp
//
//  Created by Thomas Gunter on 9/26/15.
//  Copyright © 2015 Phi Research. All rights reserved.
//

import Foundation

func doAttractiveWarp( var landmarks : [PhiPoint]) -> [PhiPoint]{
    let ans = attractive_adjusted_warp(&landmarks);
    var safeAns : [PhiPoint] = [];
    for idx in 0..<landmarks.count {
        safeAns.append((ans[Int(idx)]))
    }
    free(ans)
    return safeAns
}

func doSillyWarp( var landmarks : [PhiPoint]) -> [PhiPoint]{
    let ans = silly_adjusted_warp(&landmarks);
    var safeAns : [PhiPoint] = [];
    for idx in 0..<landmarks.count {
        safeAns.append((ans[Int(idx)]))
    }
    free(ans)
    return safeAns
}