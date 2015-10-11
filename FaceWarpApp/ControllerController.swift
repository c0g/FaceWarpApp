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
    
    
    @IBAction func prettyTouch(sender: AnyObject) {
        print("Pretty")
        delegate!.syncro.warp = WarpType.PRETTY
        redrawUI()
    }
    @IBAction func noneTouch(sender: AnyObject) {
        print("None")
        delegate!.syncro.warp = WarpType.NONE
        redrawUI()
    }
    @IBAction func animeTouch(sender: AnyObject) {
        print("Anime")
        delegate!.syncro.warp = WarpType.SILLY
        redrawUI()
    }
    @IBAction func liveTouch(sender: AnyObject) {
        print("Live")
        delegate!.syncro.warp = WarpType.DYNAMIC
        redrawUI()
    }
    @IBAction func captureTouch(sender: AnyObject) {
        print("Capture")
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
        print("Anime")
        delegate!.syncro.warp = WarpType.TINY
        redrawUI()
    }
    func redrawUI() {
//        switch delegate!.syncro.warp {
//        case .DYNAMIC:
//            
//        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    }

}