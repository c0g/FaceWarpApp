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
#import "PHItypes.h"

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

-(NSArray *) facesPointsInBigImage:(CVPixelBufferRef)bigBuff andSmallImage: (CVPixelBufferRef)smallBuff withScale: (int) scale;

@end

#endif /* PHIHarleyStreet_h */
