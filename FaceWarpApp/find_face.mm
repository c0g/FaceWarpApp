//
//  PHIHarleyStreet.m
//  FaceWarpApp
//
//  Created by Thomas Nickson on 18/09/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "find_face.h"
#import "PHItypes.h"
#include <mutex>

#include <dlib/image_processing/frontal_face_detector.h>
#include <dlib/image_processing.h>
#include <dlib/image_io.h>
#include <dlib/opencv.h>

#include <opencv2/opencv.hpp>

struct tracker_rect {
    dlib::correlation_tracker tracker;
    dlib::rectangle lastone;
};


@implementation FaceFinder {
    dlib::shape_predictor predictor;
//    std::vector<dlib::object_detector<dlib::scan_fhog_pyramid<dlib::pyramid_down<4> > > > detector;
    dlib::frontal_face_detector detector;
    NSMutableArray * facesAverage;
    NSUInteger movingAverageCount;
    
    //    std::vector<dlib::rectangle> faces;
    int retrackAfter;
    int iter;
    std::mutex mtx;
    std::vector<tracker_rect> trackers;
    dlib::rectangle face_loc;
    
    dispatch_queue_t faceQueue;
    
}

-(FaceFinder *)init {
    self = [super init];
    if (self) {
        iter = 0;
        retrackAfter = 3;
        NSString * dat_file = [[NSBundle mainBundle] pathForResource:@"facemarks" ofType:@"dat"];
//        NSString * dat_file2 = [[NSBundle mainBundle] pathForResource:@"total_detector" ofType:@"svm"];
        
        detector = dlib::get_frontal_face_detector();
        dlib::deserialize(dat_file.UTF8String) >> predictor;
//        dlib::deserialize(dat_file2.UTF8String) >> detector;
        facesAverage = [[NSMutableArray alloc] init];
        faceQueue = dispatch_queue_create("com.PHI.faceQueue", DISPATCH_QUEUE_CONCURRENT);
        movingAverageCount = 0;
    }
    return self;
};

-(FaceFinder *) initWithRetrack: (int) _retrackAfter {
    self = [self init];
    if (self) {
        retrackAfter = _retrackAfter;
    }
    return self;
}

-(NSArray *) facesPointsInBigImage:(CamImage)_bigImg andSmallImage: (CamImage)_smallImg withScale: (int) scale {
    //Convert CamImages into dlib images:
    cv::Mat bigMat(_bigImg.height, _bigImg.width, CV_8UC4, _bigImg.pixels, _bigImg.rowSize);
    dlib::cv_image<dlib::rgb_alpha_pixel> bigImg(bigMat);
    
    cv::Mat smallMatWithA(_smallImg.height, _smallImg.width, CV_8UC4, _smallImg.pixels, _smallImg.rowSize);
    dlib::cv_image<dlib::rgb_alpha_pixel> smallImg(smallMatWithA);
    std::vector<dlib::rectangle> faces = detector(smallImg);
    
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    for (auto smallFaceRect : faces) {
        dlib::rectangle faceRect{
            smallFaceRect.left() * scale,
            smallFaceRect.top() * scale,
            smallFaceRect.right() * scale,
            smallFaceRect.bottom() * scale
        };
        NSMutableArray * internalArr = [[NSMutableArray alloc] init];
        dlib::full_object_detection res = predictor(bigImg, faceRect);
        for (int pidx = 0; pidx < res.num_parts(); ++pidx) {
            [internalArr addObject: [NSValue valueWithPhiPoint:PhiPoint{static_cast<int>(res.part(pidx).x()), static_cast<int>(res.part(pidx).y())}]];
        }
        [arr addObject: internalArr];
    }
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
