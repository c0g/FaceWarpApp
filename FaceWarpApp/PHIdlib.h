//
//  PHIHarleyStreet.h
//  FaceWarpApp
//
//  Created by Thomas Nickson on 18/09/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
//#import "FaceWarpApp-Swift.h"

#ifndef PHIHarleyStreet_h
#define PHIHarleyStreet_h

typedef struct {
    uint8_t * pixels;
    int width;
    int height;
    int channels;
    int rowSize;
} CamImage;

@interface FaceFinder : NSObject

-(NSArray *) facePointsInImage: (CamImage)image withFeatures: (CIFaceFeature *) box;
//-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;

@end


#endif /* PHIHarleyStreet_h */
