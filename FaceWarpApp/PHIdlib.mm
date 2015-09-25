//
//  PHIHarleyStreet.m
//  FaceWarpApp
//
//  Created by Thomas Nickson on 18/09/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHIdlib.h"
#import "PHIRectangle.h"

#include <dlib/image_processing/frontal_face_detector.h>
#include <dlib/image_processing.h>
#include <dlib/image_io.h>
#include <dlib/opencv.h>

#include <opencv2/opencv.hpp>

dlib::rectangle dlibRectFromRectangle(Rectangle rect) {
    return dlib::rectangle(rect.left, rect.top, rect.right, rect.bottom);
}

Rectangle rectangleFromDlibRectangle(const dlib::rectangle & rect) {
    return Rectangle{
        static_cast<float>(rect.left()),
        static_cast<float>(rect.top()),
        static_cast<float>(rect.right()),
        static_cast<float>(rect.bottom())};
}

Rectangle operator*(const Rectangle & rect, float scale) {
    return Rectangle{rect.left * scale, rect.top * scale, rect.right * scale, rect.bottom * scale};
}

@implementation FaceFinder {
    dlib::shape_predictor predictor;
    dlib::frontal_face_detector detector;
    NSMutableArray * facesAverage;
    NSUInteger movingAverageCount;
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
        facesAverage = [[NSMutableArray alloc] init];
        movingAverageCount = 0;
    }
    return self;
};

-(UIImage *) UIImageFromCVMat:(cv::Mat)cvMat
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
};

-(NSArray *) facesInImage: (CamImage)img withScale: (float)scale {
    cv::Mat mat(img.height, img.width, CV_8UC4, img.pixels, img.rowSize);
    dlib::cv_image<dlib::rgb_alpha_pixel> dlib_img(mat);
    std::vector<dlib::rectangle> faces = detector(dlib_img);
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    for (auto rect : faces) {
//        std::cout << rect.left() << ", " << rect.top() << ", " << rect.right() << ", " << rect.bottom() << std::endl;
        [arr addObject: [NSValue valueWithRectangle:rectangleFromDlibRectangle(rect) * scale]];
    }
    return arr;
}



-(NSArray *) facePointsInImage: (CamImage)img withRectangle: (Rectangle)box {
    cv::Mat mat(img.height, img.width, CV_8UC4, img.pixels, img.rowSize);
//    std::cout << box.left << ", " << box.top << ", " << box.right << ", " << box.bottom << std::endl;
    dlib::cv_image<dlib::rgb_alpha_pixel> dlib_img(mat);
    dlib::rectangle rect = dlibRectFromRectangle(box);
    dlib::full_object_detection res = predictor(dlib_img, rect);
//    dlib::draw_rectangle(dlib_img, rect, dlib::rgb_alpha_pixel(255, 0, 0, 255));
//    cv::Mat dlib_cv_mat = dlib::toMat(dlib_img);
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    for (int pidx = 0; pidx < res.num_parts(); ++pidx) {
        [arr addObject: [NSValue valueWithCGPoint:CGPointMake(res.part(pidx).x(), res.part(pidx).y())]];
    }
    
//    if ( movingAverageCount == 0 )
//    {
//        for (int pidx = 0; pidx < res.num_parts(); ++pidx) {
//            [facesAverage addObject: [NSValue valueWithCGPoint:CGPointMake(res.part(pidx).x(), res.part(pidx).y())]];
//        }
//        movingAverageCount += 1;
//        
//    } else if (movingAverageCount < 2)
//    {
//        for (int pidx = 0; pidx < res.num_parts(); ++pidx) {
//            CGPoint tmp = CGPointAdd([[facesAverage objectAtIndex:pidx] CGPointValue], [[arr objectAtIndex:pidx] CGPointValue]);
//            NSValue * nsTmp = [NSValue valueWithCGPoint:tmp];
//            [facesAverage replaceObjectAtIndex:pidx withObject:nsTmp];
//           
//        }
//        movingAverageCount += 1;
//    } else if (movingAverageCount == 2)
//    {
//        for (int pidx = 0; pidx < res.num_parts(); ++pidx) {
//            CGPoint tmp = CGPointAdjustScaling([[facesAverage objectAtIndex:pidx] CGPointValue], 0.5);
//            NSValue * nsTmp = [NSValue valueWithCGPoint:tmp];
//            [facesAverage replaceObjectAtIndex:pidx withObject:nsTmp];
//            CGPoint tmp2 = CGPointAdd([[facesAverage objectAtIndex:pidx] CGPointValue], [[arr objectAtIndex:pidx] CGPointValue]);
//            NSValue * nsTmp2 = [NSValue valueWithCGPoint:tmp2];
//            [facesAverage replaceObjectAtIndex:pidx withObject:nsTmp2];
//
//            CGPoint tmp3 = CGPointAdjustScaling([[facesAverage objectAtIndex:pidx] CGPointValue], 0.5);
//            NSValue * nsTmp3 = [NSValue valueWithCGPoint:tmp3];
//            [arr replaceObjectAtIndex:pidx withObject:nsTmp3];
//        }
//    }
    return arr;
}


-(NSArray *) facePointsInImage: (CamImage) image {
    //returns CGRects and a list of points
    NSArray * arr = [[NSArray alloc] init];
    return arr;
}

CGPoint CGPointAdd(CGPoint p1, CGPoint p2)
{
    return CGPointMake(p1.x + p2.x, p1.y + p2.y);
}

CGPoint CGPointAdjustScaling(CGPoint p1, double v1)
{
    return CGPointMake(p1.x * v1, p1.y * v1);
}

@end