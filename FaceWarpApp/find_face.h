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
#import "PHIRectangle.h"

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

-(NSArray *) facesPointsInBigImage:(CamImage)bigImg andSmallImage: (CamImage)_smallImg withScale: (int) scale;


//-(NSArray *) facesInImage: (CamImage)image withScale: (float)scale;
//-(NSArray *) facePointsInImage: (CamImage)image withRectangle: (Rectangle)box;
//-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;

@end


#endif /* PHIHarleyStreet_h */
