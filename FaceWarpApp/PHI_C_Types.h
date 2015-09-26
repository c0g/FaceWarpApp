//
//  PHI_C_Types.h
//  FaceWarpApp
//
//  Created by Thomas Nickson on 26/09/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

#ifndef PHI_C_Types_h
#define PHI_C_Types_h

typedef struct {
    float left;
    float top;
    float right;
    float bottom;
} PhiRectangle;

typedef struct {
    float x;
    float y;
} PhiPoint;

typedef struct {
    int p0;
    int p1;
    int p2;
} PhiTriangle;


#endif /* PHI_C_Types_h */
