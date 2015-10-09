//
//  SpinnyController.swift
//  FaceWarpApp
//
//  Created by Thomas Nickson on 09/10/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

import Foundation
import UIKit

class SpinnyController : UIPickerView {
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("spinny!")
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        print("hittest")
        return self
    }
}
