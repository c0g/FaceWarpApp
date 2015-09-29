//
//  triangulator.cpp
//  FaceWarpApp
//
//  Created by Thomas Nickson on 26/09/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

#import <GTEngine.h>
#import "triangulator.h"
#import "Clarkson-Delaunay.h"
#include <CoreGraphics/CoreGraphics.h>
#include <stdlib.h>
#include <vector>
// factorials (multiplies example)
#include <iostream>     // std::cout
#include <algorithm>
#include <functional>   // std::multiplies
#include <numeric>      // std::partial_sum
#include <set>

std::vector<PhiTriangle> infaceTri {{ 0, 36, 17},{36, 18, 17},{36, 37, 18},{37, 19, 18},{37, 38, 19},{38, 20, 19},{38, 39, 20},{39, 21, 20},{36, 41, 37},{41, 40, 37},{40, 38, 37},{40, 39, 38},{39, 27, 21},{27, 22, 21},{27, 42, 22},{42, 23, 22},{42, 43, 23},{43, 24, 23},{43, 44, 24},{44, 25, 24},{44, 45, 25},{45, 26, 25},{45, 16, 26},{42, 47, 43},{47, 44, 43},{47, 46, 44},{46, 45, 44},{39, 28, 27},{28, 42, 27},{32, 33, 30},{33, 34, 30},{31, 30, 32},{31, 30, 29},{34, 35, 30},{35, 29, 30},{35, 28, 29},{31, 29, 28},{ 0,  1, 36},{39, 31, 28},{35, 42, 28},{15, 16, 45},{40, 31, 39},{35, 47, 42},{ 1, 41, 36},{ 1, 40, 41},{15, 45, 46},{15, 46, 47},{35, 15, 47},{ 1, 31, 40},{ 1,  2, 31},{35, 14, 15},{ 2, 48, 31},{ 3, 48,  2},{ 4, 48,  3},{54, 14, 35},{54, 13, 14},{12, 13, 54},{ 4,  5, 48},{ 5, 59, 48},{11, 12, 54},{55, 11, 54},{10, 11, 55},{56, 10, 55},{ 9, 10, 56},{ 5,  6, 59},{ 6, 58, 59},{ 6,  7, 58},{ 7, 57, 58},{ 7,  8, 57},{57,  9, 56},{ 8,  9, 57},{48, 49, 31},{53, 54, 35},{49, 50, 31},{52, 53, 35},{50, 32, 31},{52, 35, 34},{50, 51, 32},{51, 52, 34},{51, 34, 33},{51, 33, 32},{48, 60, 49},{59, 60, 48},{60, 67, 61},{64, 54, 53},{55, 54, 64},{65, 64, 63},{67, 62, 61},{65, 63, 62},{67, 66, 62},{66, 65, 62},{51, 52, 63},{61, 62, 51},{60, 61, 49},{61, 50, 49},{63, 64, 53},{63, 53, 52},{61, 51, 50},{51, 62, 63},{59, 67, 60},{59, 58, 67},{58, 57, 67},{57, 66, 67},{57, 65, 66},{57, 56, 65},{65, 55, 56},{55, 64, 65}};

PhiTriangle operator +(PhiTriangle tri, int offset) {
    return PhiTriangle{tri.p0 + offset, tri.p1 + offset, tri.p2 + offset};
}



// Needs c linkage to be imported to Swift
extern "C" {
PhiTriangle * unsafeTidyIndices(const PhiPoint * edgesLandMarks, int numEdges, int numFaces, int * nTris) {
    // CALLER TO FREE RETURN VALUE
//    gte::ConstrainedDelaunay2<float,  gte::BSNumber<gte::UIntegerAP32>> del;
    int numPoints = numEdges + 68 * numFaces;
    
    typedef gte::BSNumber<gte::UIntegerAP32> Rational;
    typedef gte::TriangulateCDT<float, Rational> Triangulator;
    
    
    std::vector<int> outerPoints;
    //push the edges to outer
    int edgesOffset = numFaces * 68;
    for (int eidx = 0; eidx < numEdges; ++eidx) {
        outerPoints.push_back(edgesOffset + eidx);
    }
    Triangulator::Polygon outer = {(int)outerPoints.size(), outerPoints.data()};
    
    std::vector<std::vector<int>> innerPoints;
    for (int fidx = 0; fidx < numFaces; fidx++) {
        int offset = fidx * 68;
        std::vector<int> innerInnerPoints;
        for (int idx = 0; idx < 27; ++idx) {
            innerInnerPoints.push_back(idx + offset);
        }
        innerPoints.push_back(innerInnerPoints);
    }
    
//    for (const auto p : outerPoints) {
//        std::cout << p << ", ";
//    }
//    std::cout << std::endl;
//    for (const auto pvec : innerPoints) {
//        for (const auto p : pvec) {
//            std::cout << p << ", ";
//        }
//    }
//    std::cout << std::endl;
    
//    std::vector<Triangulator::Polygon> inners;
//    for (auto points : innerPoints) {
    Triangulator::Polygon inner = {(int)innerPoints[0].size(), innerPoints[0].data()};
//        inners.push_back(poly);
//    }
//    
    std::vector<gte::Vector2<float>> positions;
    for (int pidx = 0; pidx < numPoints; pidx++) {
        positions.push_back(gte::Vector2<float> {
            static_cast<float>(edgesLandMarks[pidx].x),
            static_cast<float>(edgesLandMarks[pidx].y)
        });
    }
    
//    std::cout << positions.size() << std::endl;
    
    Triangulator triangulator{(int)positions.size(), positions.data()};
    triangulator(outer, inner);
    std::vector<std::array<int, 3>> triangles = triangulator.GetTriangles();
//    for (const auto tri : triangles) {
//        std::cout << tri[0] << ", " << tri[1] << ", " << tri[2] << std::endl;
//    }
    
    *nTris = numFaces * infaceTri.size() + triangles.size();
    
    PhiTriangle * faceTris = (PhiTriangle *) malloc(sizeof(PhiTriangle) * nTris[0]);
    for (int fidx = 0; fidx < numFaces; ++fidx) {
        int offset = fidx * 107;
        for (int idx = 0; idx < infaceTri.size(); idx++) {
            faceTris[offset + idx] = infaceTri.at(idx) + offset;
        }
    }
    int edgeOffset = numFaces * 107;
    for (int idx = 0; idx < triangles.size(); ++idx) {
        faceTris[edgeOffset + idx] = PhiTriangle{
            static_cast<unsigned int>(triangles.at(idx)[0]),
            static_cast<unsigned int>(triangles.at(idx)[1]),
            static_cast<unsigned int>(triangles.at(idx)[2])
        };
    }
    
    return faceTris;
}
}

