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
    let SELECTED_WARP = "PickerViewSelectedWarp"
    let WARP_PACK_1 = "PixurgeryWarpPack1"
    var titles = ["TINY", "SWAP", "ROBOT", "ANIME", "WOBBLE"]
    var hasWarpPack1 = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        self.pickerView.font = UIFont.systemFontOfSize(15)
        self.pickerView.highlightedFont = UIFont.systemFontOfSize(15)
        self.pickerView.pickerViewStyle = .Flat
        self.pickerView.maskDisabled = true
        self.pickerView.reloadData()
        
        delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let i = NSUserDefaults().integerForKey(SELECTED_WARP)
        self.pickerView.selectItem(i, animated: false)
        
//        if !IAPHelper.canMakePayments() {
//            ["TINY", "SWAP", "ROBOT"] // Don't show IAP to people who can't get them
//        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(IAPHelperProductPurchasedNotification, object: nil, queue: nil, usingBlock: {_ in
            print("got notification center")
                self.pickerView.selectItem(self.pickerView.selectedItem, animated: false)
        })
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
        NSUserDefaults().setInteger(item, forKey: SELECTED_WARP)
        var ownsWarp = true
        switch titles[item] {
        case "ANIME":
            ownsWarp = PixProducts.store.isProductPurchased(PixProducts.warppack1)
            delegate!.syncro.warp = .SILLY
        case "SWAP":
            delegate!.syncro.warp = .SWAP
        case "TINY":
            delegate!.syncro.warp = .TINY
        case "WOBBLE":
            ownsWarp = PixProducts.store.isProductPurchased(PixProducts.warppack1)
            delegate!.syncro.warp = .DYNAMIC
        case "ROBOT":
            delegate!.syncro.warp = .ROBOT
        case _:
            print("Shouldn't be here!")
        }
        delegate!.ownsWarp(ownsWarp)
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
