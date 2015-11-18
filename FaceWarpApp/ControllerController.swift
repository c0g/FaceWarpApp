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
    
    var smallUIMode : Bool = false
    
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
    @IBOutlet weak var modeselector: UIButton!
    @IBOutlet weak var cameraToggle: UIButton!
    
    func enableUI() {
        pretty.enabled = true
        anime.enabled = true
        live.enabled = true
        tiny.enabled = true
        none.enabled = true
        cameraToggle.enabled = true
        capture.enabled = true
        photoVideo.enabled = true
        swap.enabled = true
        handsome.enabled = true
        gamer.enabled = true
        modeselector.enabled = true
    }
    
    func disableUI() {
        pretty.enabled = false
        anime.enabled = false
        live.enabled = false
        tiny.enabled = false
        none.enabled = false
        cameraToggle.enabled = false
        capture.enabled = false
        photoVideo.enabled = false
        swap.enabled = false
        handsome.enabled = false
        gamer.enabled = false
        modeselector.enabled = false
    }
    
    
    @IBAction func gamerTouch(sender: AnyObject) {
        toggleUIMode()
        delegate!.syncro.warp = WarpType.ROBOT
        redrawUI()
    }

    @IBAction func modeselectorTouch(sender: AnyObject) {
        toggleUIMode()
    }
    
    func toggleUIMode() {
        if smallUIMode {
            pretty.hidden = !pretty.hidden
            anime.hidden = !anime.hidden
            live.hidden = !live.hidden
            tiny.hidden = !tiny.hidden
            none.hidden = !none.hidden
            cameraToggle.hidden = !cameraToggle.hidden
            capture.hidden = !capture.hidden
            photoVideo.hidden = !photoVideo.hidden
            swap.hidden = !swap.hidden
            handsome.hidden = !handsome.hidden
            gamer.hidden = !gamer.hidden
            modeselector.hidden = !modeselector.hidden
        }
    }
    
    @IBAction func handsomeTouch(sender: AnyObject) {
        toggleUIMode()
//        switch delegate!.syncro.warp {
//        case .HANDSOME:
//            delegate!.syncro.calibrating = true
//        case _:
//            delegate!.syncro.warp = WarpType.HANDSOME
//        }
        delegate!.syncro.warp = WarpType.HANDSOME
        redrawUI()
    }
    
    @IBAction func toggleCamera(sender: AnyObject) {
        delegate!.toggleCamera()
    }

    @IBAction func swapTouch(sender: AnyObject) {
        toggleUIMode()
        delegate!.syncro.warp = WarpType.SWAP
        redrawUI()
    }
    @IBAction func prettyTouch(sender: AnyObject) {
        toggleUIMode()
//        switch delegate!.syncro.warp {
//        case .PRETTY:
//            delegate!.syncro.calibrating = true
//        case _:
//            delegate!.syncro.warp = WarpType.PRETTY
//        }
        delegate!.syncro.warp = WarpType.PRETTY
        redrawUI()
    }
    @IBAction func noneTouch(sender: AnyObject) {
        toggleUIMode()
        delegate!.syncro.warp = WarpType.NONE
        redrawUI()
    }
    @IBAction func animeTouch(sender: AnyObject) {
        toggleUIMode()
        delegate!.syncro.warp = WarpType.SILLY
        redrawUI()
    }
    @IBAction func liveTouch(sender: AnyObject) {
        toggleUIMode()
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
        toggleUIMode()
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
        case .DYNAMIC:
            live.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            modeselector.setTitle("Live", forState: UIControlState.Normal)
        case .NONE:
            none.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            modeselector.setTitle("None", forState: UIControlState.Normal)
        case .PRETTY:
            pretty.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            modeselector.setTitle("Pretty", forState: UIControlState.Normal)
        case .HANDSOME:
            handsome.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            modeselector.setTitle("Handsome", forState: UIControlState.Normal)
        case .ROBOT:
            gamer.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            modeselector.setTitle("Robot", forState: UIControlState.Normal)
        case .SILLY:
            anime.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            modeselector.setTitle("Anime", forState: UIControlState.Normal)
        case .TINY:
            tiny.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            modeselector.setTitle("Tiny", forState: UIControlState.Normal)
        case .SWAP:
            swap.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            modeselector.setTitle("Swap", forState: UIControlState.Normal)
        case _:print("Go fuck yourself")
        }
        
        delegate?.hideInstructions(!delegate!.syncro.calibrating)
//        if delegate!.syncro.calibrating {
//            pretty.setTitle("Pretty", forState: UIControlState.Normal)
//            handsome.setTitle("Handsome", forState: UIControlState.Normal)
//        } else {
//            switch delegate!.syncro.warp {
//            case .PRETTY:
//                pretty.setTitle("Calibrate", forState: UIControlState.Normal)
//                handsome.setTitle("Handsome", forState: UIControlState.Normal)
//            case .HANDSOME:
//                pretty.setTitle("Pretty", forState: UIControlState.Normal)
//                handsome.setTitle("Calibrate", forState: UIControlState.Normal)
//            case _:
//                pretty.setTitle("Pretty", forState: UIControlState.Normal)
//                handsome.setTitle("Handsome", forState: UIControlState.Normal)
//            }
//        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate!.ui = self
        
        redrawUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        if modeselector.superview != nil {
            print("small ui")
            smallUIMode = true
        } else {
            print("big ui")
            smallUIMode = false
            pretty.hidden = false
            anime.hidden = false
            live.hidden = false
            tiny.hidden = false
            none.hidden = false
            cameraToggle.hidden = false
            capture.hidden = false
            photoVideo.hidden = false
            swap.hidden = false
            handsome.hidden = false
            gamer.hidden = false
            modeselector.hidden = false
        }
        redrawUI()
    }

}