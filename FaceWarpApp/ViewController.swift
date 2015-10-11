//
//  ViewController.swift
//  iOSSwiftOpenGL
//
//  Created by Bradley Griffith on 6/29/14.
//  Copyright (c) 2014 Bradley Griffith. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var openGLView: OpenGLView!

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
    
    override func shouldAutorotate() -> Bool {
        let del = UIApplication.sharedApplication().delegate as! AppDelegate
        if del.syncro.capturing && del.syncro.capture_type == .VIDEO {
            return false
        } else {
            return true
        }
    }
}

