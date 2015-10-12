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
    @IBOutlet weak var switch2d: UIButton!
    @IBOutlet weak var switch3d: UIButton!

    
    @IBAction func switch3dTouch(sender: AnyObject) {
        delegate!.syncro.warp = WarpType.SWAP3D
        redrawUI()
    }
    @IBAction func switch2dTouch(sender: AnyObject) {
        delegate!.syncro.warp = WarpType.SWAP2D
        redrawUI()
    }
    @IBAction func prettyTouch(sender: AnyObject) {
        delegate!.syncro.warp = WarpType.PRETTY
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
            capture.setTitle("Capture", forState: UIControlState.Normal)
        }
    }
    
    func redrawUI() {
        pretty.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        anime.setTitleColor(UIColor.grayColor(), forState: .Normal)
        live.setTitleColor(UIColor.grayColor(), forState: .Normal)
        tiny.setTitleColor(UIColor.grayColor(), forState: .Normal)
        none.setTitleColor(UIColor.grayColor(), forState: .Normal)
        switch2d.setTitleColor(UIColor.grayColor(), forState: .Normal)
        switch3d.setTitleColor(UIColor.grayColor(), forState: .Normal)
        
        switch delegate!.syncro.warp {
        case .DYNAMIC: live.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        case .NONE: none.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        case .PRETTY: pretty.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        case .SILLY: anime.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        case .TINY: tiny.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        case .SWAP2D: switch2d.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        case .SWAP3D: switch3d.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        case _:print("Go fuck yourself")
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