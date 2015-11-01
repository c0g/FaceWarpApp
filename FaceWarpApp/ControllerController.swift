//
//  ControllerController.swift
//  FaceWarpApp
//
//  Created by Thomas Nickson on 09/10/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

import Foundation
import UIKit

class ControllerController : UIViewController {
    
    var delegate : AppDelegate? = nil
    @IBOutlet weak var pretty: UIButton!
    @IBOutlet weak var anime: UIButton!
    @IBOutlet weak var live: UIButton!
    @IBOutlet weak var tiny: UIButton!
    @IBOutlet weak var none: UIButton!
    @IBOutlet weak var capture: UIButton!
    @IBOutlet weak var photoVideo: UISegmentedControl!
    @IBOutlet weak var swap: UIButton!
    @IBOutlet weak var handsome: UIButton!
    @IBOutlet weak var gamer: UIButton!
    
    
    @IBAction func gamerTouch(sender: AnyObject) {
        delegate!.syncro.warp = WarpType.ROBOT
        redrawUI()
    }

    @IBAction func handsomeTouch(sender: AnyObject) {
        switch delegate!.syncro.warp {
        case .HANDSOME:
            delegate!.syncro.calibrating = true
        case _:
            delegate!.syncro.warp = WarpType.HANDSOME
        }
        redrawUI()
    }
    
    @IBAction func toggleCamera(sender: AnyObject) {
        delegate!.toggleCamera()
    }

    @IBAction func swapTouch(sender: AnyObject) {
        delegate!.syncro.warp = WarpType.SWAP
        redrawUI()
    }
    @IBAction func prettyTouch(sender: AnyObject) {
        switch delegate!.syncro.warp {
        case .PRETTY:
            delegate!.syncro.calibrating = true
        case _:
            delegate!.syncro.warp = WarpType.PRETTY
        }
        redrawUI()
    }
    @IBAction func noneTouch(sender: AnyObject) {
        delegate!.syncro.warp = WarpType.NONE
        redrawUI()
    }
    @IBAction func animeTouch(sender: AnyObject) {
        delegate!.syncro.warp = WarpType.SILLY
        redrawUI()
    }
    @IBAction func liveTouch(sender: AnyObject) {
        delegate!.syncro.warp = WarpType.DYNAMIC
        redrawUI()
    }
    @IBAction func captureTouch(sender: AnyObject) {
        delegate?.syncro.capturing = true
        redrawUI()
    }
    @IBAction func selValChange(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            delegate?.syncro.capture_type = .IMAGE
        case 1:
            delegate?.syncro.capture_type = .VIDEO
        case _:
            print("fucked error")
        }
    }
    
    @IBAction func tinyTouch(sender: UIButton) {
        delegate!.syncro.warp = WarpType.TINY
        redrawUI()
    }
    
    func recordTime(time : Int) {
        if time > 0 {
            capture.setTitle(String(time), forState: .Normal)
        } else {
            capture.setTitle("", forState: UIControlState.Normal)
        }
    }
    
    func redrawUI() {
        pretty.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        anime.setTitleColor(UIColor.grayColor(), forState: .Normal)
        live.setTitleColor(UIColor.grayColor(), forState: .Normal)
        tiny.setTitleColor(UIColor.grayColor(), forState: .Normal)
        none.setTitleColor(UIColor.grayColor(), forState: .Normal)
        swap.setTitleColor(UIColor.grayColor(), forState: .Normal)
        handsome.setTitleColor(UIColor.grayColor(), forState: .Normal)
        gamer.setTitleColor(UIColor.grayColor(), forState: .Normal)
        
        switch delegate!.syncro.warp {
        case .DYNAMIC: live.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        case .NONE: none.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        case .PRETTY: pretty.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        case .HANDSOME: handsome.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        case .ROBOT: gamer.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        case .SILLY: anime.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        case .TINY: tiny.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        case .SWAP: swap.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        case _:print("Go fuck yourself")
        }
        
        delegate?.hideInstructions(!delegate!.syncro.calibrating)
        if delegate!.syncro.calibrating {
            pretty.setTitle("Pretty", forState: UIControlState.Normal)
            handsome.setTitle("Handsome", forState: UIControlState.Normal)
        } else {
            switch delegate!.syncro.warp {
            case .PRETTY:
                pretty.setTitle("Calibrate", forState: UIControlState.Normal)
                handsome.setTitle("Handsome", forState: UIControlState.Normal)
            case .HANDSOME:
                pretty.setTitle("Pretty", forState: UIControlState.Normal)
                handsome.setTitle("Calibrate", forState: UIControlState.Normal)
            case _:
                pretty.setTitle("Pretty", forState: UIControlState.Normal)
                handsome.setTitle("Handsome", forState: UIControlState.Normal)
            }
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate!.ui = self
        redrawUI()
    }

}