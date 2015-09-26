//
//  normalise_warp.hpp
//  FaceWarpApp
//
//  Created by Thomas Gunter on 9/25/15.
//  Copyright © 2015 Phi Research. All rights reserved.
//

#ifndef normalise_warp_h
#define normalise_warp_h

#include <dlib/matrix/matrix.h>
#include <dlib/optimization.h>
#include "face_landmarks.hpp"

dlib::matrix<double> return_rotation_matrix_from_flat_vector(const dlib::matrix<double,6,1> &vector)
{
    dlib::matrix<double> rotation_matrix_cholesky(3,3);
    rotation_matrix_cholesky = vector(0,0), 0.0,         0.0,
                               vector(1,0), vector(2,0), 0.0,
                               vector(3,0), vector(4,0), vector(5,0);
    dlib::matrix<double,3,3> rotation_matrix = rotation_matrix_cholesky * dlib::trans(rotation_matrix_cholesky);
    
    return rotation_matrix;
};

double cost_function_3d_rotation(dlib::matrix<double> vector, const dlib::matrix<double> &landmarks3d, const dlib::matrix<double> &landmarks){
    
    dlib::matrix<double,3,3> rotation_matrix = return_rotation_matrix_from_flat_vector(vector);
    
    dlib::matrix<double> rotated_3d_landmarks = landmarks3d * rotation_matrix;
    dlib::matrix<double> rotated_3d_landmarks_subm = dlib::colm(rotated_3d_landmarks, dlib::range(0,1));
    dlib::matrix<double> mismatch_error = dlib::sum_cols(dlib::sqrt(dlib::pow(2, rotated_3d_landmarks_subm - landmarks)));
    dlib::matrix<double> mismatch_error_covariance = dlib::trans(mismatch_error) * mismatch_error;
    dlib::matrix<double> mismatch_error_final = dlib::trans(mismatch_error) * mismatch_error_covariance * mismatch_error;
    
    double error = mismatch_error_final(0,0);
    return error;
};

double cost_function_2d_rotation(dlib::matrix<double> angle, const dlib::matrix<double> &centered_landmarks)
{
    dlib::matrix<double,2,2> rotation_matrix = dlib::rotation_matrix(angle(0,0));
    dlib::matrix<double> rotated_landmarks = centered_landmarks * rotation_matrix;
    
    dlib::matrix<long> dlib_leye_range(1,leye_dlib.size());
    for (int i = 0; i < leye_dlib.size(); i++ )
    {
        dlib_leye_range(0,i) = (long)leye_dlib[i];
    }
    
    dlib::matrix<long> dlib_reye_range(1,reye_dlib.size());
    for (int i = 0; i < reye_dlib.size(); i++ )
    {
        dlib_reye_range(0,i) = (long)reye_dlib[i];
    }
    
    dlib::matrix<double> old_mean_leye_tmp = dlib::rowm(centered_landmarks, dlib_leye_range);
    dlib::matrix<double> old_mean_leye = dlib::sum_rows(old_mean_leye_tmp) * (1.0/((double)leye_dlib.size()));
    dlib::matrix<double> old_mean_reye_tmp = dlib::rowm(centered_landmarks, dlib_reye_range);
    dlib::matrix<double> old_mean_reye = dlib::sum_rows(old_mean_reye_tmp) * (1.0/((double)reye_dlib.size()));
    
    dlib::matrix<double> mean_leye_tmp = dlib::rowm(rotated_landmarks, dlib_leye_range);
    dlib::matrix<double> mean_leye = dlib::sum_rows(mean_leye_tmp) * (1.0/((double)leye_dlib.size()));
    dlib::matrix<double> mean_reye_tmp = dlib::rowm(rotated_landmarks, dlib_reye_range);
    dlib::matrix<double> mean_reye = dlib::sum_rows(mean_reye_tmp) * (1.0/((double)leye_dlib.size()));

    double mismatch_error = std::numeric_limits<double>::max();
    
    if ((old_mean_leye(0,1) > old_mean_reye(0,1)) & (mean_leye(0,1) > mean_reye(0,1)))
    {
        mismatch_error = std::sqrt(std::pow(mean_leye(0,1) - mean_reye(0,1),2));
    }
    
    else if ((old_mean_leye(0,1) < old_mean_reye(0,1)) & (mean_leye(0,1) < mean_reye(0,1)))
    {
        mismatch_error = std::sqrt(std::pow(mean_leye(0,1) - mean_reye(0,1),2));
    }
    
    else if (mean_leye(0,1) == mean_reye)
    {
        mismatch_error = 0.0;
    }
    
    else
    {
        mismatch_error = std::numeric_limits<double>::max();
    };
    
    return mismatch_error;
    
};

dlib::matrix<double> find_2d_rotation_matrix(const dlib::matrix<double> &landmarks)
{
    dlib::matrix<double> mean_landmarks = dlib::rowm(landmarks,30);
    dlib::matrix<double> centered_landmarks = landmarks;
    dlib::set_colm(centered_landmarks,0) = colm(centered_landmarks,0) - mean_landmarks(0,0);
    dlib::set_colm(centered_landmarks,1) = colm(centered_landmarks,1) - mean_landmarks(0,1);
    
    auto cost_function_2d_rotation_wrapper = [&landmarks](dlib::matrix<double,1,1> x)
    {
        return cost_function_2d_rotation(x, landmarks);
    };
    
    dlib::matrix<double,1,1> angle;
    angle = 0.0;
    double min_f;
    double dervative_eps = 1e-7;
    
    dlib::find_min_using_approximate_derivatives(dlib::lbfgs_search_strategy(5),
                                                 dlib::objective_delta_stop_strategy(1e-5),
                                                 cost_function_2d_rotation_wrapper,
                                                 angle,
                                                 min_f,
                                                 dervative_eps);
    
    dlib::matrix<double,2,2> rotation_matrix_2d = dlib::rotation_matrix(angle(0,0));
    dlib::matrix<double,2,2> rotation_matrix_2d_inv = dlib::inv(rotation_matrix_2d);
//    dlib::matrix<double,3,3> rotation_matrix = dlib::identity_matrix<double>(3);
    dlib::matrix<double,3,3> rotation_matrix_inv = dlib::identity_matrix<double>(3);
//    dlib::set_subm(rotation_matrix, dlib::range(0,1), dlib::range(0,1)) = rotation_matrix_2d;
    dlib::set_subm(rotation_matrix_inv, dlib::range(0,1), dlib::range(0,1)) = rotation_matrix_2d_inv;
    
    return rotation_matrix_inv;
};

dlib::matrix<double> find_3d_rotation_matrix(const dlib::matrix<double> &landmarks, const dlib::matrix<double> &landmarks3d)
{
    dlib::matrix<double> mean_landmarks = dlib::rowm(landmarks,30);
    dlib::matrix<double> centered_landmarks = landmarks;
    dlib::set_colm(centered_landmarks,0) = colm(centered_landmarks,0) - mean_landmarks(0,0);
    dlib::set_colm(centered_landmarks,1) = colm(centered_landmarks,1) - mean_landmarks(0,1);
    
    dlib::matrix<double> mean_landmarks3d = dlib::rowm(landmarks3d,30);
    dlib::matrix<double> centered_landmarks3d = landmarks3d;
    dlib::set_colm(centered_landmarks3d,0) = colm(centered_landmarks3d,0) - mean_landmarks3d(0,0);
    dlib::set_colm(centered_landmarks3d,1) = colm(centered_landmarks3d,1) - mean_landmarks3d(0,1);
    dlib::set_colm(centered_landmarks3d,2) = colm(centered_landmarks3d,2) - mean_landmarks3d(0,2);
    
    auto cost_function_3d_rotation_wrapper = [&landmarks3d, &landmarks](dlib::matrix<double,6,1> x)
    {
        return cost_function_3d_rotation(x, landmarks3d, landmarks);
    };
    
    dlib::matrix<double,6,1> vector;
    vector = 1.0, 0.0, 1.0, 0.0, 0.0, 1.0;
    
    double min_f;
    double dervative_eps = 1e-7;
    
    dlib::find_min_using_approximate_derivatives(dlib::lbfgs_search_strategy(5),
                                                 dlib::objective_delta_stop_strategy(1e-5),
                                                 cost_function_3d_rotation_wrapper,
                                                 vector,
                                                 min_f,
                                                 dervative_eps);
    
    dlib::matrix<double,3,3> rotation_matrix = return_rotation_matrix_from_flat_vector(vector);
    
    return rotation_matrix;
    
};

dlib::matrix<double> find_overall_rotation_matrix(const dlib::matrix<double> &landmarks, const dlib::matrix<double> &landmarks3d)
{
    dlib::matrix<double,3,3> rotation_matrix_2d_inv = find_2d_rotation_matrix(landmarks);
    dlib::matrix<double,3,3> rotation_matrix_3d = find_3d_rotation_matrix(landmarks, landmarks3d);
    
    dlib::matrix<double,3,3> rotation_matrix_total = rotation_matrix_3d * rotation_matrix_2d_inv;
    
    return rotation_matrix_total;
};

double * return_3d_adjusted_warp(const dlib::matrix<double> &landmarks, const dlib::matrix<double> &face_flat_warp)
{
    // CALLER MUST FREE MEMORY ON RETURN.
    dlib::matrix<double> mean_landmarks = dlib::rowm(landmarks,30);
    dlib::matrix<double> centered_landmarks = landmarks;
    dlib::set_colm(centered_landmarks,0) = colm(centered_landmarks,0) - mean_landmarks(0,0);
    dlib::set_colm(centered_landmarks,1) = colm(centered_landmarks,1) - mean_landmarks(0,1);
    
    double *dlib_3d = landmarks3d_dlib;
    dlib::matrix<double> rotation_matrix = find_overall_rotation_matrix(landmarks, dlib::mat(dlib_3d, 68, 3));
    
    dlib::matrix<double> new_warp = centered_landmarks * rotation_matrix;
    dlib::matrix<double> new_warp_de_centered = new_warp;
    dlib::set_colm(new_warp_de_centered,0) = colm(new_warp_de_centered,0) + mean_landmarks(0,0);
    dlib::set_colm(new_warp_de_centered,1) = colm(new_warp_de_centered,1) + mean_landmarks(0,1);
    
    double * output = (double *)malloc(new_warp_de_centered.nr()*new_warp_de_centered.nc()*sizeof(double));
    int index = 0;
    for (int row = 0; row < new_warp_de_centered.nr(); row++)
    {
        for (int col = 0; col < new_warp_de_centered.nc(); col++)
        {
            index++;
            output[index] = new_warp_de_centered(row,col);
        }
    }
    return output;
};

#endif /* normalise_warp_h */
