//
//  Warpnormalise.swift
//  FaceWarpApp
//
//  Created by Thomas Gunter on 9/26/15.
//  Copyright © 2015 Phi Research. All rights reserved.
//

import Foundation

enum WarpType {
    case PRETTY, HANDSOME, SILLY, NONE, TINY, DYNAMIC, SWAP
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
//            return doAttractiveWarp2(landmarks, initParam: &face_log[idx].parameters)
            return doAttractiveWarpPretty(landmarks, initParam: &face_log[idx].parameters)
        case .HANDSOME:
            return doAttractiveWarpHandsome(landmarks, initParam: &face_log[idx].parameters)
        case .SILLY:
            return doSillyWarp(landmarks, initParam: &face_log[idx].parameters)
        case .DYNAMIC:
            return doDynamicWarp(landmarks, initParam: &face_log[idx].parameters)
        case .TINY:
            return doTinyFaceWarp(landmarks, initParam: &face_log[idx].parameters)
        case .NONE:
            return (landmarks, 0.0)
        case _:
            return (landmarks, 0.0)
        }
    }
    
    func doSwitchFace2D(all_landmarks : [[PhiPoint]]) -> ([[PhiPoint]], [Float64]) {
        let num_faces = all_landmarks.count
        var factr : [Float64] = Array(count: num_faces, repeatedValue: 0.0)
        
        var tmp_faces = all_landmarks
        for idx in 0..<(num_faces+1)/2 {
            let idx1 = idx*2
            let idx2 = (idx1 + 1) % num_faces
            var face1 = all_landmarks[idx1]
            var face2 = all_landmarks[idx2]
            
            if idx1 + 1  >=  num_faces{
                face1 = all_landmarks[idx1]
                face2 = tmp_faces[idx2]
            }
        
            let pidx1 = findBestFace(face1)
            let pidx2 = findBestFace(face2)
            
            
//            let (warped_faces, factr1, factr2) = doSwap(face1, landmarks2: face2, initParam1: &face_log[pidx1].parameters, initParam2: &face_log[pidx2].parameters)
            let (warped_faces, factr1, factr2) = doShitSwap(face1, landmarks2: face2, initParam1: &face_log[pidx1].parameters, initParam2: &face_log[pidx2].parameters)
            let warped1 = Array(warped_faces[0..<68])
            let warped2 = Array(warped_faces[68..<136])

            tmp_faces[idx1] = warped1
            tmp_faces[idx2] = warped2
            factr[idx1] = factr1
            factr[idx2] = factr2
        }
        return(tmp_faces, factr)
    }
    
    func doSwitchFace3D(all_landmarks : [[PhiPoint]]) -> ([[PhiPoint]], [Float64]) {
        let num_faces = all_landmarks.count
        var factr : [Float64] = Array(count: num_faces, repeatedValue: 0.0)
        
        var tmp_faces = all_landmarks
        for idx in 0..<(num_faces+1)/2 {
            let idx1 = idx * 2
            let idx2 = (idx1 + 1) % num_faces
            var face1 = all_landmarks[idx1]
            var face2 = all_landmarks[idx2]
            
            let pidx1 = findBestFace(face1)
            let pidx2 = findBestFace(face2)
            
            
            let (warped_faces, factr1, factr2) = doSwap(face1, landmarks2: face2, initParam1: &face_log[pidx1].parameters, initParam2: &face_log[pidx2].parameters)
//            let (warped_faces, factr1, factr2) = doShitSwap(face1, landmarks2: face2, initParam1: &face_log[pidx1].parameters, initParam2: &face_log[pidx2].parameters)
            let warped1 = Array(warped_faces[0..<68])
            let warped2 = Array(warped_faces[68..<136])
            tmp_faces[idx1] = warped1
            tmp_faces[idx2] = warped2
            factr[idx1] = factr1
            factr[idx2] = factr2
        }
        return(tmp_faces, factr)
    }
    
    func doShitSwap( var landmarks1 : [PhiPoint], var landmarks2 : [PhiPoint], inout initParam1 : [CDouble],  inout initParam2 : [CDouble]) -> ([PhiPoint], Float64, Float64) {
        var concat = landmarks2
        concat.appendContentsOf(landmarks1)
        return (concat, 0.0, 0.0)
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
        let ans = attractive_adjusted_warp(&landmarks, &initParam, &factr);
        var safeAns : [PhiPoint] = [];
        for idx in 0..<landmarks.count {
            safeAns.append((ans[Int(idx)]))
        }
        free(ans)
        
        return (safeAns, factr)
    }
    
    func doAttractiveWarpPretty( var landmarks : [PhiPoint], inout initParam : [CDouble]) -> ([PhiPoint], Float64) {
        var factr : Float64 = 0
        let ans = attractive_adjusted_warp_pretty(&landmarks, &initParam, &factr);
        var safeAns : [PhiPoint] = [];
        for idx in 0..<landmarks.count {
            safeAns.append((ans[Int(idx)]))
        }
        free(ans)
        
        return (safeAns, factr)
    }
    
    func doAttractiveWarpHandsome( var landmarks : [PhiPoint], inout initParam : [CDouble]) -> ([PhiPoint], Float64) {
        var factr : Float64 = 0
        let ans = attractive_adjusted_warp_pretty(&landmarks, &initParam, &factr);
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
    
    func doDynamicWarp( var landmarks : [PhiPoint], inout initParam : [CDouble]) -> ([PhiPoint], Float64) {
        var factr : Float64 = 0
        let ans = dynamic_adjusted_warp(&landmarks, &initParam, &factr);
        var safeAns : [PhiPoint] = [];
        for idx in 0..<landmarks.count {
            safeAns.append((ans[Int(idx)]))
        }
        free(ans)
        return (safeAns, 0.0)
    }
    
    func doTinyFaceWarp( var landmarks : [PhiPoint], inout initParam : [CDouble]) -> ([PhiPoint], Float64) {
        var factr : Float64 = 0
        let ans = tiny_face_warp(&landmarks, &initParam, &factr);
        var safeAns : [PhiPoint] = [];
        for idx in 0..<landmarks.count {
            safeAns.append((ans[Int(idx)]))
        }
        free(ans)
        return (safeAns, factr)
    }
    
    func doSwap( var landmarks1 : [PhiPoint], var landmarks2 : [PhiPoint], inout initParam1 : [CDouble],  inout initParam2 : [CDouble]) -> ([PhiPoint], Float64, Float64) {
        var factr1 : Float64 = 0.0
        var factr2 : Float64 = 0.0
//        var param1 : [Float64]
        let ans = face_swap_warp(&landmarks1, &landmarks2, &initParam1, &initParam2, &factr1, &factr2)
        var safeAns : [PhiPoint] = [];
        for idx in 0..<(landmarks1.count + landmarks2.count) {
            safeAns.append((ans[Int(idx)]))
        }
        free(ans)
        return (safeAns, factr1, factr2)
    }
}