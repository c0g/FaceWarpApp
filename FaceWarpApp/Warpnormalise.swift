//
//  Warpnormalise.swift
//  FaceWarpApp
//
//  Created by Thomas Gunter on 9/26/15.
//  Copyright © 2015 Phi Research. All rights reserved.
//

import Foundation

enum WarpType {
    case PRETTY, SILLY
}

class Warper {
    
    struct Face {
        let landmarks : [PhiPoint]
        var parameters : [CDouble]
        let time : NSDate
    }
    var face_log : [Face] = []
    
    func doWarp (landmarks : [PhiPoint], warp : WarpType) -> ([PhiPoint], Float64) {
        // Check if we've seen this before
        let idx = findBestFace(landmarks)
        switch warp {
        case .PRETTY:
            return doAttractiveWarp2(landmarks, initParam: &face_log[idx].parameters)
        case .SILLY:
            return doSillyWarp(landmarks, initParam: &face_log[idx].parameters)
        }
    }
    
    func findBestFace(landmarks : [PhiPoint]) -> Int {
        //prune facelibrary - if it's more than 10second old assume it's stale
        var temp_face_log : [Face] = []
        let now : NSDate = NSDate()
        for face in face_log {
            if now.timeIntervalSinceDate(face.time) < 10 {
                temp_face_log.append(face)
            }
        }
        face_log = temp_face_log
        //calculate sum of squared distances from our face library
        var distances : [Float] = []
        for face in face_log {
            var dist : Float = 0.0
            for (p_now, p_log) in zip(landmarks, face.landmarks) {
                dist += sqrt(pow(Float(p_now.x - p_log.x), 2) + pow(Float(p_now.y - p_log.y), 2))
            }
            distances.append(dist)
        }
        // Find the minimum and the index of the minimum
        let (idx, min) = distances.enumerate().reduce((Int(-1), Float(100000000.0))) {
            $0.1 < $1.1 ? $0 : $1
        }
        if min > 1000.0 {
            if face_log.count > 5 {
                face_log.removeFirst()
            }
            face_log.append(Face(landmarks: landmarks, parameters: [0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0], time: NSDate()))
            return face_log.count - 1
        } else {
            return idx
        }
    }
    
    func doAttractiveWarp( var landmarks : [PhiPoint], inout initParam : [CDouble]) -> ([PhiPoint], Float64) {
        var factr : Float64 = 0
        let ans = attractive_adjusted_warp(&landmarks, &initParam, &factr);
        var safeAns : [PhiPoint] = [];
        for idx in 0..<landmarks.count {
            safeAns.append((ans[Int(idx)]))
        }
        free(ans)

        return (safeAns, factr)
    }
    
    func doAttractiveWarp2( var landmarks : [PhiPoint], inout initParam : [CDouble]) -> ([PhiPoint], Float64) {
        var factr : Float64 = 0
        let ans = attractive_adjusted_warp2(&landmarks, &initParam, &factr);
        var safeAns : [PhiPoint] = [];
        for idx in 0..<landmarks.count {
            safeAns.append((ans[Int(idx)]))
        }
        free(ans)
        
        return (safeAns, factr)
    }

    func doSillyWarp( var landmarks : [PhiPoint], inout initParam : [CDouble]) -> ([PhiPoint], Float64) {
        var factr : Float64 = 0
        let ans = silly_adjusted_warp(&landmarks, &initParam, &factr);
        var safeAns : [PhiPoint] = [];
        for idx in 0..<landmarks.count {
            safeAns.append((ans[Int(idx)]))
        }
        free(ans)
        return (safeAns, factr)
    }
}