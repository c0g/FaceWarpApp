//
//  CaptureController.swift
//  FaceWarpApp
//
//  Created by Thomas Nickson on 22/11/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

import Foundation

class CaptureController : UIViewController, MWPhotoBrowserDelegate, AKPickerViewDataSource, AKPickerViewDelegate {
    let albumName = "Pixurgery"
    @IBOutlet var pickerView: AKPickerView!
    var delegate : AppDelegate? = nil
    
    var images : [MWPhoto] = []
    var thumbs : [MWPhoto] = []
    var uithumb : UIImage? = nil
    
    @IBOutlet weak var capture: UIButton!
    @IBOutlet weak var openGrid: UIButton!
    @IBOutlet weak var selectCamera: UIButton!
    @IBAction func capturePressed(sender: AnyObject) {
        if delegate!.syncro.capturing {
            delegate!.syncro.capturing = false
        } else {
            delegate!.syncro.capturing = true
        }
    }
    @IBAction func selectCameraPressed(sender: AnyObject) {
        delegate?.toggleCamera()
    }
    func updateUI() {
        
    }
    
    func pulseAlbum() {
        
    }
    func fillImages(collection : PHAssetCollection) {
        images = []
        thumbs = []
        let result = PHAsset.fetchAssetsInAssetCollection(collection, options: nil)
        for idx in 0..<result.count {
            let screen = UIScreen.mainScreen()
            let scale = screen.scale
            let imageSize = max(screen.bounds.size.width, screen.bounds.size.height) * 1.5;
            let thumbSize = min(screen.bounds.size.width, screen.bounds.size.height) * 0.5;
            let imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
            let thumbTargetSize = CGSizeMake(thumbSize * scale, thumbSize * scale);
            let asset = result.objectAtIndex(idx) as! PHAsset
            let photo = MWPhoto(asset: asset, targetSize: imageTargetSize)
            images.append(photo)
            thumbs.append(MWPhoto(asset: asset, targetSize: thumbTargetSize))
            
        }
        images = images.reverse()
        thumbs = thumbs.reverse()
    }
    
    @IBAction func albumPressed(sender: AnyObject) {
        let browser = MWPhotoBrowser(delegate: self)
        // Set options
        browser.displayActionButton = true; // Show action button to allow sharing, copying, etc (defaults to YES)
        browser.displayNavArrows = false; // Whether to display left and right nav arrows on toolbar (defaults to NO)
        browser.displaySelectionButtons = false; // Whether selection buttons are shown on each image (defaults to NO)
        browser.zoomPhotosToFill = true; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
        browser.alwaysShowControls = true; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
        browser.enableGrid = true; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
        browser.startOnGrid = true; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
        browser.autoPlayOnAppear = false; // Auto-play first video
        
        //Check if the folder exists, if not, create it
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection:PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        var assetCollection : PHAssetCollection? = nil
        if let first_Obj:AnyObject = collection.firstObject{
            //found the album
            //            albumFound = true
            assetCollection = first_Obj as! PHAssetCollection
            fillImages(assetCollection!)
            self.navigationController?.pushViewController(browser, animated: true)
        }else{
            //Album placeholder for the asset collection, used to reference collection in completion handler
            var albumPlaceholder:PHObjectPlaceholder!
            //create the folder
            NSLog("\nFolder \"%@\" does not exist\nCreating now...", albumName)
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(self.albumName)
                albumPlaceholder = request.placeholderForCreatedAssetCollection
                },
                completionHandler: {(success:Bool, error:NSError?)in
                    if(success){
                        print("Successfully created folder")
                        //                        self.albumFound = true
                        let collection = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([albumPlaceholder.localIdentifier], options: nil)
                        assetCollection = collection.firstObject as! PHAssetCollection
                        self.fillImages(assetCollection!)
                        self.navigationController?.pushViewController(browser, animated: true)
                    }else{
                        print("Error creating folder")
                        //                        self.albumFound = false
                    }
            })
        }

        
    }
    
    func didRotate() {
        switch UIDevice.currentDevice().orientation {
        case .LandscapeLeft:
            print("Landscape left")
//            [UIView animateWithDuration:0.6f delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
//                self.view.autoresizesSubviews = NO;
//                [self.buttoner setTransform:CGAffineTransformRotate(self.buttoner.transform, 90.0f)];
//                } completion:nil];
            UIView.animateWithDuration(0.3, delay: 0.0,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: {
                self.capture.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                self.openGrid.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                self.selectCamera.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                }, completion: nil)

        case .LandscapeRight:
            print("Landscape right")
            UIView.animateWithDuration(0.3, delay: 0.0,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: {
                self.capture.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI_2))
                self.openGrid.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI_2))
                self.selectCamera.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI_2))
            }, completion: nil)
                case .PortraitUpsideDown:
            print("Portrait Upside Down")
            UIView.animateWithDuration(0.3, delay: 0.0,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: {
                self.capture.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                self.openGrid.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                self.selectCamera.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            }, completion: nil)
        case _:
            print("Portrait or other")
            UIView.animateWithDuration(0.3, delay: 0.0,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: {
                self.capture.transform = CGAffineTransformMakeRotation(CGFloat(0))
                self.openGrid.transform = CGAffineTransformMakeRotation(CGFloat(0))
                self.selectCamera.transform = CGAffineTransformMakeRotation(CGFloat(0))
            }, completion: nil)

        }
    }
    
    let titles = ["IMAGE", "VIDEO"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRotate", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        self.pickerView.font = UIFont.boldSystemFontOfSize(13)
        self.pickerView.highlightedFont = UIFont.boldSystemFontOfSize(13)
        self.pickerView.pickerViewStyle = .Wheel
        self.pickerView.maskDisabled = false
        self.pickerView.reloadData()
        
        delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate!.ui = self
        updateImageIcon()
    }
    
    func wobbleOpenGrid() {
        var current = 0.0
        switch UIDevice.currentDevice().orientation {
        case .LandscapeRight:
            current = -M_PI_2
        case .LandscapeLeft:
            current = M_PI_2
        case .PortraitUpsideDown:
            current = M_PI
        case _:
            current = 0.0
            }
        UIView.animateWithDuration(0.1, delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: {
                self.openGrid.transform = CGAffineTransformMakeRotation(CGFloat(current + M_PI / 8))
            }, completion: nil)
        UIView.animateWithDuration(0.1, delay: 0.1,
            options: UIViewAnimationOptions.CurveLinear,
            animations: {
                self.openGrid.transform = CGAffineTransformMakeRotation(CGFloat(current - M_PI / 8))
            }, completion: nil)
        UIView.animateWithDuration(0.1, delay: 0.2,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.openGrid.transform = CGAffineTransformMakeRotation(CGFloat(current))
            }, completion: nil)
    }
    
    func updateImageIcon() {
//        dispatch_sync(dispatch_get_main_queue()) {
            //Check if the folder exists, if not, create it
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", self.albumName)
            let collection:PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
            var assetCollection : PHAssetCollection? = nil
            if let first_Obj:AnyObject = collection.firstObject{
                //found the album
                //            albumFound = true
                assetCollection = first_Obj as! PHAssetCollection
                let result = PHAsset.fetchAssetsInAssetCollection(assetCollection!, options: nil)
                let manager = PHImageManager.defaultManager()
                var option = PHImageRequestOptions()

                if let asset = result.lastObject as? PHAsset {
                    option.synchronous = false
                    option.resizeMode = PHImageRequestOptionsResizeMode.Fast
                    option.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
                    manager.requestImageForAsset(asset, targetSize: CGSize(width: 50.0, height: 50.0), contentMode: .AspectFit, options: option, resultHandler: {(result, info)->Void in
                        self.openGrid.setImage(result, forState: .Normal)
                        self.wobbleOpenGrid()
                    })
                }
            }else{
                //Album placeholder for the asset collection, used to reference collection in completion handler
                var albumPlaceholder:PHObjectPlaceholder!
                //create the folder
                NSLog("\nFolder \"%@\" does not exist\nCreating now...", self.albumName)
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(self.albumName)
                    albumPlaceholder = request.placeholderForCreatedAssetCollection
                    },
                    completionHandler: {(success:Bool, error:NSError?)in
                        if(success){
                            print("Successfully created folder")
                            //                        self.albumFound = true
                            let collection = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([albumPlaceholder.localIdentifier], options: nil)
                            assetCollection = collection.firstObject as! PHAssetCollection
                            let result = PHAsset.fetchAssetsInAssetCollection(assetCollection!, options: nil)
                            let manager = PHImageManager.defaultManager()
                            var option = PHImageRequestOptions()
                            if let asset = result.lastObject as? PHAsset {
                                option.synchronous = false
                                option.resizeMode = PHImageRequestOptionsResizeMode.Fast
                                option.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
                                manager.requestImageForAsset(asset, targetSize: CGSize(width: 50.0, height: 50.0), contentMode: .AspectFit, options: option, resultHandler: {(result, info)->Void in
                                    self.openGrid.setImage(result, forState: .Normal)
                                    self.wobbleOpenGrid()
                                })
                            }
                            }else{
                            print("Error creating folder")
                            //                        self.albumFound = false
                        }
                })
            }
//        }

    }
    
    func enableUI() {
        self.pickerView.hidden = false
        self.selectCamera.hidden = false
        self.openGrid.hidden = false
    }
    
    func disableUI() {
        self.pickerView.hidden = true
        self.selectCamera.hidden = true
        self.openGrid.hidden = true
    }
    
    func recordTime(time : Int) {

        if time > 0 {
            capture.setTitle(String(time), forState: .Normal)
        } else {
            capture.setTitle("", forState: UIControlState.Normal)
        }
    }
    
    
    
    
//    - (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
//    return self.photos.count;
//    }
//    
//    - (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
//    if (index < self.photos.count) {
//    return [self.photos objectAtIndex:index];
//    }
//    return nil;
//    }
    
//    - (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index;
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, thumbPhotoAtIndex index: UInt) -> MWPhotoProtocol! {
        return thumbs[Int(index)]
    }
    
    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(images.count)
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
        return images[Int(index)]
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
            delegate?.syncro.capture_type = .IMAGE
        case 1:
            delegate?.syncro.capture_type = .VIDEO
        case _:
            print("Shouldn't be here!")
        }
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
        // println("\(scrollView.contentOffset.x)")
    }

}