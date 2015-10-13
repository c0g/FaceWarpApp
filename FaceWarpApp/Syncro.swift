//
//  Singleton.swift
//  FaceWarpApp
//
//  Created by Thomas Nickson on 09/10/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

import Foundation

enum CaptureType {
    case VIDEO, IMAGE
}

class Syncro {
    var warp: WarpType = WarpType.SILLY
    var capturing : Bool = false
    var capture_type : CaptureType = CaptureType.IMAGE
}
