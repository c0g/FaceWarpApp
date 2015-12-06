//
//  WarpController.swift
//  FaceWarpApp
//
//  Created by Thomas Nickson on 22/11/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

import Foundation

class WarpController : UIViewController, AKPickerViewDataSource, AKPickerViewDelegate  {
    @IBOutlet var pickerView: AKPickerView!
    var delegate : AppDelegate? = nil
    
    let titles = ["ANIME", "SWAP", "TINY", "WOBBLE", "ROBOT"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        self.pickerView.font = UIFont.systemFontOfSize(15)
        self.pickerView.highlightedFont = UIFont.systemFontOfSize(15)
        self.pickerView.pickerViewStyle = .Flat
        self.pickerView.maskDisabled = false
        self.pickerView.reloadData()
        
        delegate = UIApplication.sharedApplication().delegate as! AppDelegate

    }
    
    // MARK: - AKPickerViewDataSource
    
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
        return self.titles.count
    }
    
    /*
    Image Support
    -------------
    Please comment '-pickerView:titleForItem:' entirely and
    uncomment '-pickerView:imageForItem:' to see how it works.
    */
    
    func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> String {
        return self.titles[item]
    }
    
    func pickerView(pickerView: AKPickerView, imageForItem item: Int) -> UIImage {
        return UIImage(named: self.titles[item])!
    }
    
    // MARK: - AKPickerViewDelegate
    
    func pickerView(pickerView: AKPickerView, didSelectItem item: Int) {
        print("You have selected \(self.titles[item])")
        switch item {
        case 0:
            delegate!.syncro.warp = .SILLY
        case 1:
            delegate!.syncro.warp = .SWAP
        case 2:
            delegate!.syncro.warp = .TINY
        case 3:
            delegate!.syncro.warp = .DYNAMIC
        case 4:
            delegate!.syncro.warp = .ROBOT
        case _:
            print("Shouldn't be here!")
        }
    }
    
    func pickerView(pickerView: AKPickerView, didStopScrollingAtItem item: Int) {
        print("Stopped")
    }
    
    /*
    Label Customization
    -------------------
    You can customize labels by their any properties (except for fonts,)
    and margin around text.
    These methods are optional, and ignored when using images.
    */
    
    /*
    func pickerView(pickerView: AKPickerView, configureLabel label: UILabel, forItem item: Int) {
    label.textColor = UIColor.lightGrayColor()
    label.highlightedTextColor = UIColor.whiteColor()
    label.backgroundColor = UIColor(
    hue: CGFloat(item) / CGFloat(self.titles.count),
    saturation: 1.0,
    brightness: 0.5,
    alpha: 1.0)
    }
    */
    func pickerView(pickerView: AKPickerView, marginForItem item: Int) -> CGSize {
    return CGSizeMake(10, 10)
    }

    
    /*
    UIScrollViewDelegate Support
    ----------------------------
    AKPickerViewDelegate inherits UIScrollViewDelegate.
    You can use UIScrollViewDelegate methods
    by simply setting pickerView's delegate.
    */
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        print("scrolling")
    }

}