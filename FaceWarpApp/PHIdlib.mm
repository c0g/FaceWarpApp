//
//  PHIHarleyStreet.m
//  FaceWarpApp
//
//  Created by Thomas Nickson on 18/09/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHIdlib.h"

#include <dlib/image_processing/frontal_face_detector.h>
#include <dlib/image_processing.h>
#include <dlib/image_io.h>
#include <dlib/opencv.h>

#include <opencv2/opencv.hpp>

@implementation FaceFinder {
    dlib::shape_predictor predictor;
    dlib::frontal_face_detector detector;
    dispatch_queue_t concurrent_queue;
    std::unique_ptr<double[]> dogget;
    dlib::rectangle face_loc;
    int iter;
}

-(FaceFinder *)init {
    self = [super init];
    if (self) {
        iter = 0;
        NSString * dat_file = [[NSBundle mainBundle] pathForResource:@"shape_predictor" ofType:@"dat"];
        detector = dlib::get_frontal_face_detector();
        dlib::deserialize(dat_file.UTF8String) >> predictor;
        concurrent_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    }
    return self;
};

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}



-(NSArray *) facePointsInImage: (CamImage)img withFeatures: (CIFaceFeature *)box {
    cv::Mat mat(img.height, img.width, CV_8UC4, img.pixels, img.rowSize);
    dlib::cv_image<dlib::rgb_alpha_pixel> dlib_img(mat);
    float img_width = img.width;
    float img_height = img.height;
    CGFloat left = (box.bounds.origin.y  - img_height / 2) * 1.1 + img_height / 2;
    CGFloat bottom = (box.bounds.origin.x  - img_width / 2) * 1 + img_width / 2;
    CGFloat right = (box.bounds.origin.y + box.bounds.size.height - img_height / 2) * 1.1 + img_height / 2;
    CGFloat top = (box.bounds.origin.x + box.bounds.size.width - img_width / 2) * 1 + img_width / 2;
    face_loc = detector(dlib_img)[0];
//    std::vector<dlib::rectangle> valz = detector(dlib_img);
    dlib::rectangle rect(top, left, bottom, right);
    dlib::full_object_detection res = predictor(dlib_img, face_loc);
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    for (int pidx = 0; pidx < res.num_parts(); ++pidx) {
        [arr addObject: [NSValue valueWithCGPoint:CGPointMake(res.part(pidx).x(), res.part(pidx).y())]];
    }
    
    
//    cv::Mat cvMat;
//    dlib::draw_rectangle(dlib_img, rect, dlib::rgb_alpha_pixel(255, 255, 255, 255));
//    dlib::dpoint bottom_left{left, bottom};
//    dlib::draw_solid_circle(dlib_img, bottom_left, 10, dlib::rgb_alpha_pixel(255, 255, 0, 255));
//    
//    dlib::toMat(dlib_img).copyTo(cvMat);
////    dlib_img .copyTo(cvMat);
////    
//    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
//    CGColorSpaceRef colorSpace;
//    
//    if (cvMat.elemSize() == 1) {
//        colorSpace = CGColorSpaceCreateDeviceGray();
//    } else {
//        colorSpace = CGColorSpaceCreateDeviceRGB();
//    }
//    
//    
//    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
//    
//    // Creating CGImage from cv::Mat
//    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
//                                        cvMat.rows,                                 //height
//                                        8,                                          //bits per component
//                                        8 * cvMat.elemSize(),                       //bits per pixel
//                                        cvMat.step[0],                            //bytesPerRow
//                                        colorSpace,                                 //colorspace
//                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
//                                        provider,                                   //CGDataProviderRef
//                                        NULL,                                       //decode
//                                        false,                                      //should interpolate
//                                        kCGRenderingIntentDefault                   //intent
//                                        );
//    
//    
//    // Getting UIImage from CGImage
//    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
//    CGImageRelease(imageRef);
//    CGDataProviderRelease(provider);
//    CGColorSpaceRelease(colorSpace);

    return arr;
}


-(NSArray *) facePointsInImage: (CamImage) image {
    //returns CGRects and a list of points
    NSArray * arr = [[NSArray alloc] init];
    return arr;
}


@end