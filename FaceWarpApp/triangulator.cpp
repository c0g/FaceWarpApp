//
//  triangulator.cpp
//  FaceWarpApp
//
//  Created by Thomas Nickson on 26/09/2015.
//  Copyright © 2015 Phi Research. All rights reserved.
//

#import "triangulator.h"
#import "Clarkson-Delaunay.h"
#include <stdlib.h>
#include <vector>
// factorials (multiplies example)
#include <iostream>     // std::cout
#include <functional>   // std::multiplies
#include <numeric>      // std::partial_sum
#include <set>

int distinct_abs(const std::vector<int>& v)
{
    std::set<int> distinct_container;
    
    for(auto curr_int = v.begin(), end = v.end(); // no need to call v.end() multiple times
        curr_int != end;
        ++curr_int)
    {
        // std::set only allows single entries
        // since that is what we want, we don't care that this fails
        // if the second (or more) of the same value is attempted to
        // be inserted.
        distinct_container.insert(abs(*curr_int));
    };
    
    return distinct_container.size();
};

template <typename T>
std::vector<Triangle> triangulate(int num_faces, const std::vector<int> edge_points, const std::vector<T> &landmarks, const std::vector<T> &delaunay){
    // Delaunay is a
    long a = 0;
    double b = static_cast<double>(a);
    
    std::vector<Triangle> tri;
    
    std::vector<int> range_of_end_points;
    for( int i = 0; i < num_faces; i++ ){
        range_of_end_points.push_back( ((i + 1) * 68) - 1 );
    };
    
    std::vector<int> range_of_interior_points;
    for (int face_num = 0; face_num < num_faces; face_num++){
        for( int i = 27 + face_num * 68; i < 67 + face_num * 68; i++ ){
            range_of_interior_points.push_back( i );
        };
    };
    
    
    for( int i = 0; i < delaunay.size(); i++ )
    {
        if (check_intersection(delaunay[i], edge_points)){
            tri.push_back(delaunay[i]);
        }
        else
        {
            std::vector<int> sums;
            
            for (int j = 0; j < range_of_end_points.size(); j++){
                sums[j] = 0;
                if (range_of_end_points[j] >= delaunay[i]){
                    sums[j] += 1;
                };
            };
            if ((distinct_abs(sums) > 1) | (tri_el_in_interior(delaunay[i], range_of_interior_points))){
                tri.push_back(delaunay[i]);
            };
        };
    };
    for (int k = 0; k < num_faces; k++){
        int offset = 68*k;
        for (int p = 0; p < tri.size(); p++){
            Triangle tri_now = tri[p];
            std::transform(&tri_now, &tri_now+3, &tri_now+3, std::bind1st(std::multiplies<T>(),offset));
            tri.push_back(tri_now);
        };
    };
    return tri;
};

int check_intersection(const std::vector<int> &v1, const std::vector<int> &v2){
    std::vector<int> v;
    v.resize(v1.size() + v2.size());
    std::vector<int>::iterator it;
    
    std::sort(v1,v1.begin()+v1.size());
    std::sort(v2,v2.begin()+v2.size());
    
    it=std::set_intersection (v1, v1.begin()+v1.size(), v2, v2.begin()+v2.size(), v.begin());
    v.resize(it-v.begin());
    return (v.size() > 0);
};

bool tri_el_not_in_interior(const std::vector<int>& delaunay_el, const std::vector<int>& range_of_interior_points){
    int sum = 0;
    for (int i = 0; i < delaunay_el.size(); i++){
        if (std::find(range_of_interior_points.begin(), range_of_interior_points.end(), delaunay_el[i]) != range_of_interior_points.end()){
            sum += 1;
        };
    };
    
    bool flag = false;
    if (sum > 0){
        flag = true;
    };
    return flag;
};



// Needs c linkage to be imported to Swift
extern "C" {
int * tidyIndices(int * edges, int nEdges, int * landMarks, int nFaces, int * nTris) {
    // CALLER TO FREE RETURN VALUE
    int numVertices;
    int dim = 2;
    unsigned int * result = BuildTriangleIndexList(point_list, 0, nPoints, dim, 0, &numVertices);
    
}
}