//
//  normalise_warp.cpp
//  FaceWarpApp
//
//  Created by Thomas Gunter on 9/26/15.
//  Copyright © 2015 Phi Research. All rights reserved.
//

#include <stdio.h>
#include "normalise_warp.h"

#include <dlib/matrix/matrix.h>
#include <dlib/optimization.h>
#include "face_landmarks.hpp"

typedef dlib::matrix<double,0,1> column_vector;

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
    dlib::matrix<double> mismatch_error = dlib::sum_cols(dlib::sqrt(dlib::pow(rotated_3d_landmarks_subm - landmarks,2)));
//    dlib::matrix<double> mismatch_error_covariance = dlib::trans(mismatch_error) * mismatch_error;
//    dlib::matrix<double> mismatch_error_final = dlib::trans(mismatch_error) * mismatch_error_covariance * mismatch_error;
    
//    double error = mismatch_error_final(0,0);
    double error = dlib::sum_rows(mismatch_error);
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
    
    double mismatch_error = 68*2*100000;//std::numeric_limits<double>::max();

    mismatch_error = std::sqrt(std::pow(mean_leye(0,1) - mean_reye(0,1),2));
    
    return mismatch_error;
    
};

dlib::matrix<double> find_2d_rotation_matrix(const dlib::matrix<double> &landmarks, double * startAngle)
{
    dlib::matrix<double> mean_landmarks = dlib::rowm(landmarks,30);
    dlib::matrix<double> centered_landmarks = landmarks;
    dlib::set_colm(centered_landmarks,0) = colm(centered_landmarks,0) - mean_landmarks(0,0);
    dlib::set_colm(centered_landmarks,1) = colm(centered_landmarks,1) - mean_landmarks(0,1);
    
    auto cost_function_2d_rotation_wrapper = [&centered_landmarks](double x)
    {
        dlib::matrix<double, 1, 1> arse;
        arse = x;
        auto cost = cost_function_2d_rotation(arse, centered_landmarks);
//        std::cout << "Cost: "<< cost << " for x: " << x <<std::endl;
        return cost;
    };
    
//    column_vector angle(1);
    double angle = startAngle[0];
    double min_f;
    double dervative_eps = 1e-7;
    
//    const double begin = -1e200,
//    const double end = 1e200,
//    const double eps = 1e-3,
//    const long max_iter = 100,
//    const double initial_search_radius = 1
    try {
        dlib::find_min_single_variable(
                                       cost_function_2d_rotation_wrapper,
                                       angle,
                                       -3.1,
                                       3.1,
                                       1e-7,
                                       100,
                                       1e-2);
//        dlib::find_min_using_approximate_derivatives(dlib::cg_search_strategy(),
//                                                     dlib::gradient_norm_stop_strategy(1e-7),
//                                                     cost_function_2d_rotation_wrapper,
//                                                     angle,
//                                                     min_f,
//                                                     1e-9);
//        std::cout << dlib::csv << angle << std::endl;
    }
    catch (std::exception &e)
    {
        std::cout << e.what() << std::endl;
    };
//    std::cout << "started with " << startAngle[0] << " ended with " << angle << std::endl;
    angle = (angle + startAngle[0]) / 2;
    startAngle[0] = angle;
//    dlib::matrix<double> 
    dlib::matrix<double,2,2> rotation_matrix_2d = dlib::rotation_matrix(angle);
    dlib::matrix<double,2,2> rotation_matrix_2d_inv = dlib::inv(rotation_matrix_2d);
    //    dlib::matrix<double,3,3> rotation_matrix = dlib::identity_matrix<double>(3);
    dlib::matrix<double,3,3> rotation_matrix_inv = dlib::identity_matrix<double>(3);
    //    dlib::set_subm(rotation_matrix, dlib::range(0,1), dlib::range(0,1)) = rotation_matrix_2d;
    dlib::set_subm(rotation_matrix_inv, dlib::range(0,1), dlib::range(0,1)) = rotation_matrix_2d_inv;
    
    return rotation_matrix_inv;
};

dlib::matrix<double> find_3d_rotation_matrix(const dlib::matrix<double> &landmarks, const dlib::matrix<double> &landmarks3d, double * matrixParams)
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
    
    auto cost_function_3d_rotation_wrapper = [&centered_landmarks3d, &centered_landmarks](dlib::matrix<double,6,1> x)
    {
        return cost_function_3d_rotation(x, centered_landmarks3d, centered_landmarks);
    };
    
    column_vector vector(6);
    for (int i = 0; i < 6; ++i) {
        vector(i) = matrixParams[i];
    }
    
    try {
//        double min_f;
//        double dervative_eps = 1e-7;
        
        dlib::find_min_using_approximate_derivatives(dlib::bfgs_search_strategy(),
                                                     dlib::objective_delta_stop_strategy(1e-3),
                                                     cost_function_3d_rotation_wrapper,
                                                     vector,
                                                     1e-5);
        
        
        
//        find_min_bobyqa(cost_function_3d_rotation_wrapper,
//                        vector,
//                        15,    // number of interpolation points
//                        dlib::uniform_matrix<double>(6,1, -100),  // lower bound constraint
//                        dlib::uniform_matrix<double>(6,1, 100),   // upper bound constraint
//                        10,    // initial trust region radius
//                        1e-2,  // stopping trust region radius
//                        1000    // max number of objective function evaluations
//                        );
//        
//    std::cout << dlib::csv << return_rotation_matrix_from_flat_vector(vector) << std::endl;
    }
    catch (std::exception& e)
    {
        std::cout << "Optimisation failed with " << e.what() << std::endl;
    };
    for (int i = 0; i < 6; ++i) {
        vector(i) = (vector(i) + matrixParams[i]) / 2; // Average
        matrixParams[i] = vector(i); // Average
    }
    dlib::matrix<double,3,3> rotation_matrix = return_rotation_matrix_from_flat_vector(vector);
    
    return rotation_matrix;
    
};

dlib::matrix<double> find_overall_rotation_matrix(const dlib::matrix<double> &landmarks, const dlib::matrix<double> &landmarks3d, double * parameters)
{
    dlib::matrix<double,3,3> rotation_matrix_2d_inv = find_2d_rotation_matrix(landmarks, parameters);
    dlib::matrix<double,2,2> rotation_matrix_2d_2b2 = dlib::inv(dlib::subm(rotation_matrix_2d_inv,dlib::range(0,1),dlib::range(0,1)));
    
    dlib::matrix<double,3,3> rotation_matrix_3d = find_3d_rotation_matrix(landmarks*rotation_matrix_2d_2b2, landmarks3d, parameters + 1);
    
    dlib::matrix<double,3,3> rotation_matrix_total = rotation_matrix_3d * rotation_matrix_2d_inv;
    
    return rotation_matrix_total;
};

PhiPoint * return_3d_adjusted_warp(int * landmarks_ptr, int * face_flat_warp_ptr, double * parameters)
{
    // CALLER MUST FREE MEMORY ON RETURN.
    dlib::matrix<int, 68, 2> landmarks_i = dlib::mat(landmarks_ptr, 68, 2);
    dlib::matrix<double, 68, 2> landmarks = dlib::matrix_cast<double>(landmarks_i);
    
    dlib::matrix<int, 68, 2> face_flat_warp_i = dlib::mat(face_flat_warp_ptr, 68, 2);
    dlib::matrix<double, 68, 2> face_flat_warp = dlib::matrix_cast<double>(face_flat_warp_i);
    
    dlib::matrix<double> mean_landmarks = dlib::rowm(landmarks,30);
    dlib::matrix<double> centered_landmarks = landmarks;
    dlib::set_colm(centered_landmarks,0) = colm(centered_landmarks,0) - mean_landmarks(0,0);
    dlib::set_colm(centered_landmarks,1) = colm(centered_landmarks,1) - mean_landmarks(0,1);
    
    double *dlib_3d = landmarks3d_dlib;
    dlib::matrix<double,68,3> landmarks3d = dlib::mat(dlib_3d, 68, 3);
    dlib::matrix<double> mean_landmarks3d = dlib::rowm(landmarks3d,30);
    dlib::matrix<double> centered_landmarks3d = landmarks3d;
    dlib::set_colm(centered_landmarks3d,0) = colm(centered_landmarks3d,0) - mean_landmarks3d(0,0);
    dlib::set_colm(centered_landmarks3d,1) = colm(centered_landmarks3d,1) - mean_landmarks3d(0,1);
    dlib::set_colm(centered_landmarks3d,2) = colm(centered_landmarks3d,2) - mean_landmarks3d(0,2);
    
    dlib::matrix<double> mean_face_flat = dlib::rowm(face_flat_warp,30);
    dlib::matrix<double> centered_face_flat_warp = face_flat_warp;
    dlib::set_colm(centered_face_flat_warp,0) = colm(face_flat_warp,0) - mean_face_flat(0,0);
    dlib::set_colm(centered_face_flat_warp,1) = colm(face_flat_warp,1) - mean_face_flat(0,1);
    
    double stdev_landmarks3d[2];
    stdev_landmarks3d[0] = dlib::stddev(dlib::colm(centered_landmarks3d,0));
    stdev_landmarks3d[1] = dlib::stddev(dlib::colm(centered_landmarks3d,1));
    
    double stdev_face_flat_warp[2];
    stdev_face_flat_warp[0] = dlib::stddev(dlib::colm(centered_face_flat_warp,0));
    stdev_face_flat_warp[1] = dlib::stddev(dlib::colm(centered_face_flat_warp,1));
    
    dlib::set_colm(centered_landmarks3d,0) = dlib::colm(centered_face_flat_warp,0) * ((double)stdev_landmarks3d[0] / (double)stdev_face_flat_warp[0]);
    dlib::set_colm(centered_landmarks3d,1) = dlib::colm(centered_face_flat_warp,1) * ((double)stdev_landmarks3d[1] / (double)stdev_face_flat_warp[1]);
    
    dlib::matrix<double> rotation_matrix = find_overall_rotation_matrix(centered_landmarks, centered_landmarks3d, parameters);
    
    dlib::matrix<double,68,3> new_warp = centered_landmarks3d * rotation_matrix;
    dlib::matrix<double,68,2> new_warp_de_centered = dlib::subm(new_warp,dlib::range(0,67),dlib::range(0,1));
    dlib::set_colm(new_warp_de_centered,0) = colm(new_warp_de_centered,0) + mean_landmarks(0,0);
    dlib::set_colm(new_warp_de_centered,1) = colm(new_warp_de_centered,1) + mean_landmarks(0,1);
    
    PhiPoint * output = (PhiPoint *)malloc(new_warp_de_centered.nr()*sizeof(PhiPoint));
    for (int row = 0; row < new_warp_de_centered.nr(); row++)
    {
        output[row] = PhiPoint{
            static_cast<int>(std::lround(new_warp_de_centered(row,0))),
            static_cast<int>(std::lround(new_warp_de_centered(row,1)))
        };
    
    };
    return output;
};

PhiPoint * return_3d_attractive_adjusted_warp(int * landmarks_ptr, double * parameters)
{
    // CALLER MUST FREE MEMORY ON RETURN.
    const double eye_scaling = 1.1;
    
    dlib::matrix<int, 68, 2> landmarks_i = dlib::mat(landmarks_ptr, 68, 2);
//    std::cout << landmarks_i << std::endl;
    dlib::matrix<double, 68, 2> landmarks = dlib::matrix_cast<double>(landmarks_i);
//    std::cout << landmarks << std::endl;
    
    dlib::matrix<double> mean_landmarks = dlib::rowm(landmarks,30);
    dlib::matrix<double> centered_landmarks = landmarks;
    dlib::set_colm(centered_landmarks,0) = colm(centered_landmarks,0) - mean_landmarks(0,0);
    dlib::set_colm(centered_landmarks,1) = colm(centered_landmarks,1) - mean_landmarks(0,1);
    
//    double *dlib_3d = landmarks3d_dlib;
    double *dlib_3d = landmarks3d_male;
    
    dlib::matrix<double,68,3> landmarks3d = dlib::mat(dlib_3d, 68, 3);
    dlib::matrix<double> mean_landmarks3d = dlib::rowm(landmarks3d,30);
    dlib::matrix<double> centered_landmarks3d = landmarks3d;
    dlib::set_colm(centered_landmarks3d,0) = colm(centered_landmarks3d,0) - mean_landmarks3d(0,0);
    dlib::set_colm(centered_landmarks3d,1) = colm(centered_landmarks3d,1) - mean_landmarks3d(0,1);
    dlib::set_colm(centered_landmarks3d,2) = colm(centered_landmarks3d,2) - mean_landmarks3d(0,2);
    
    dlib::matrix<double> rotation_matrix = find_overall_rotation_matrix(centered_landmarks, centered_landmarks3d, parameters);
    
    dlib::matrix<double,68,3> flattened_2d_landmarks_full = centered_landmarks3d * rotation_matrix;
    dlib::set_subm(flattened_2d_landmarks_full, dlib::range(0,67), dlib::range(0,1)) = centered_landmarks;
    dlib::matrix<double,68,3> flattened_2d_landmarks_full_rotated = flattened_2d_landmarks_full * dlib::inv(rotation_matrix);
    
    dlib::matrix<long> dlib_leye_range(1,leye_dlib.size());
    for (int i = 0; i < leye_dlib.size(); i++ )
    {
        dlib_leye_range(0,i) = (long)leye_dlib[i];
    }
    dlib::matrix<double> dlib_leye = dlib::subm(flattened_2d_landmarks_full_rotated, dlib_leye_range, dlib::range(0,2));
    
    double dlib_leye_mean[2];
    dlib_leye_mean[0] = dlib::mean(dlib::colm(dlib_leye,0));
    dlib_leye_mean[1] = dlib::mean(dlib::colm(dlib_leye,1));
    
    dlib::set_colm(dlib_leye,0) = ((dlib::colm(dlib_leye,0) - dlib_leye_mean[0]) * eye_scaling) + dlib_leye_mean[0];
    dlib::set_colm(dlib_leye,1) = ((dlib::colm(dlib_leye,1) - dlib_leye_mean[1]) * eye_scaling) + dlib_leye_mean[1];
    
    dlib::matrix<long> dlib_reye_range(1,reye_dlib.size());
    for (int i = 0; i < reye_dlib.size(); i++ )
    {
        dlib_reye_range(0,i) = (long)reye_dlib[i];
    }
    dlib::matrix<double> dlib_reye = dlib::subm(flattened_2d_landmarks_full_rotated, dlib_reye_range, dlib::range(0,2));
    
    double dlib_reye_mean[2];
    dlib_reye_mean[0] = dlib::mean(dlib::colm(dlib_reye,0));
    dlib_reye_mean[1] = dlib::mean(dlib::colm(dlib_reye,1));
    
    dlib::set_colm(dlib_reye,0) = ((dlib::colm(dlib_reye,0) - dlib_reye_mean[0]) * eye_scaling) + dlib_reye_mean[0];
    dlib::set_colm(dlib_reye,1) = ((dlib::colm(dlib_reye,1) - dlib_reye_mean[1]) * eye_scaling) + dlib_reye_mean[1];
    
    dlib::set_subm(flattened_2d_landmarks_full_rotated, dlib_leye_range, dlib::range(0,2)) = dlib_leye;
    dlib::set_subm(flattened_2d_landmarks_full_rotated, dlib_reye_range, dlib::range(0,2)) = dlib_reye;

    
    dlib::matrix<long> switch_list(1,exchange_list_nose_chin_warp.size());
    for (int i = 0; i < exchange_list_nose_chin_warp.size(); i++ )
    {
        switch_list(0,i) = (long)exchange_list_nose_chin_warp[i];
    }
    
    
//    exchange_list_nose_warp
//    dlib::matrix<long> switch_list(1,exchange_list_nose_chin_warp.size());
//    for (int i = 0; i < exchange_list_nose_chin_warp.size(); i++ )
//    {
//        switch_list(0,i) = (long)exchange_list_nose_chin_warp[i];
//    }
    
    dlib::set_subm(flattened_2d_landmarks_full_rotated, switch_list, dlib::range(0,1)) = dlib::subm(centered_landmarks3d, switch_list, dlib::range(0,1));
    
    dlib::matrix<double, 68,2> _2d_landmarks_full;
    _2d_landmarks_full = dlib::subm(flattened_2d_landmarks_full_rotated * rotation_matrix, dlib::range(0,67), dlib::range(0,1));
    
    
    
//    std::cout << dlib::csv << dlib::range(0,5) <<std::endl;
//    std::cout << dlib::csv << switch_list << std::endl;
//    std::cout << "\n" << "\n";
    
    
//    dlib::set_subm(_2d_landmarks_full, switch_list, dlib::range(0,1)) = dlib::subm(flattened_2d_landmarks_full, switch_list, dlib::range(0,1));
    
//    dlib::set_colm(_2d_landmarks_full,0) = colm(_2d_landmarks_full,0) + mean_landmarks(0,0);
//    dlib::set_colm(_2d_landmarks_full,1) = colm(_2d_landmarks_full,1) + mean_landmarks(0,1);
    
    dlib::set_colm(_2d_landmarks_full,0) = colm(_2d_landmarks_full,0) + mean_landmarks(0,0);
    dlib::set_colm(_2d_landmarks_full,1) = colm(_2d_landmarks_full,1) + mean_landmarks(0,1);
    
    PhiPoint * output = (PhiPoint *)malloc(_2d_landmarks_full.nr()*sizeof(PhiPoint));
    for (int row = 0; row < _2d_landmarks_full.nr(); row++)
    {
        output[row] = PhiPoint{
            static_cast<int>(std::round(_2d_landmarks_full(row,0))),
            static_cast<int>(std::round(_2d_landmarks_full(row,1)))
        };
        
    }
//    std::cout << dlib::csv << landmarks << std::endl;
//    std::cout << dlib::csv << _2d_landmarks_full<<std::endl;
//    for (int row = 0; row < _2d_landmarks_full.nr(); row++)
//    {
//        std::cout << output[row].x << "," << output[row].y << std::endl;
//        std::cout << landmarks(row,0) << "," << landmarks(row,1) << std::endl;
//        std::cout << "\n";
//    }
//    std::cout << "\n";
//    std::cout << "\n";

    
//    exit(1);
    return output;
};

PhiPoint * return_3d_attractive_adjusted_warp2(int * landmarks_ptr, double * parameters)
{
    // CALLER MUST FREE MEMORY ON RETURN.
    const double nose_scaling_x = 0.85;
    const double nose_scaling_y = 0.95;
    
    const double eye_scaling_x = 1.07;
    const double eye_scaling_y = 1.07;
    
    dlib::matrix<int, 68, 2> landmarks_i = dlib::mat(landmarks_ptr, 68, 2);
    
    dlib::matrix<double, 68, 2> landmarks = dlib::matrix_cast<double>(landmarks_i);
    
    dlib::matrix<double> mean_landmarks = dlib::rowm(landmarks,30);
    dlib::matrix<double> centered_landmarks = landmarks;
    dlib::set_colm(centered_landmarks,0) = colm(centered_landmarks,0) - mean_landmarks(0,0);
    dlib::set_colm(centered_landmarks,1) = colm(centered_landmarks,1) - mean_landmarks(0,1);
    
    double *dlib_3d = landmarks3d_dlib;
    dlib::matrix<double,68,3> landmarks3d = dlib::mat(dlib_3d, 68, 3);
    dlib::matrix<double> mean_landmarks3d = dlib::rowm(landmarks3d,30);
    dlib::matrix<double> centered_landmarks3d = landmarks3d;
    dlib::set_colm(centered_landmarks3d,0) = colm(centered_landmarks3d,0) - mean_landmarks3d(0,0);
    dlib::set_colm(centered_landmarks3d,1) = colm(centered_landmarks3d,1) - mean_landmarks3d(0,1);
    dlib::set_colm(centered_landmarks3d,2) = colm(centered_landmarks3d,2) - mean_landmarks3d(0,2);
    
    dlib::matrix<double> rotation_matrix = find_overall_rotation_matrix(centered_landmarks, centered_landmarks3d, parameters);
    
    dlib::matrix<double,68,3> flattened_2d_landmarks_full = centered_landmarks3d * rotation_matrix;
    dlib::set_subm(flattened_2d_landmarks_full, dlib::range(0,67), dlib::range(0,1)) = centered_landmarks;
    dlib::matrix<double,68,3> flattened_2d_landmarks_full_rotated = flattened_2d_landmarks_full * dlib::inv(rotation_matrix);
    
    dlib::matrix<long> dlib_leye_range(1,leye_dlib.size());
    for (int i = 0; i < leye_dlib.size(); i++ )
    {
        dlib_leye_range(0,i) = (long)leye_dlib[i];
    }
    dlib::matrix<double> dlib_leye = dlib::subm(flattened_2d_landmarks_full_rotated, dlib_leye_range, dlib::range(0,2));
    
    double dlib_leye_mean[2];
    dlib_leye_mean[0] = dlib::mean(dlib::colm(dlib_leye,0));
    dlib_leye_mean[1] = dlib::mean(dlib::colm(dlib_leye,1));
    
    dlib::set_colm(dlib_leye,0) = ((dlib::colm(dlib_leye,0) - dlib_leye_mean[0]) * eye_scaling_x) + dlib_leye_mean[0];
    dlib::set_colm(dlib_leye,1) = ((dlib::colm(dlib_leye,1) - dlib_leye_mean[1]) * eye_scaling_y) + dlib_leye_mean[1];
    
    dlib::matrix<long> dlib_reye_range(1,reye_dlib.size());
    for (int i = 0; i < reye_dlib.size(); i++ )
    {
        dlib_reye_range(0,i) = (long)reye_dlib[i];
    }
    dlib::matrix<double> dlib_reye = dlib::subm(flattened_2d_landmarks_full_rotated, dlib_reye_range, dlib::range(0,2));
    
    double dlib_reye_mean[2];
    dlib_reye_mean[0] = dlib::mean(dlib::colm(dlib_reye,0));
    dlib_reye_mean[1] = dlib::mean(dlib::colm(dlib_reye,1));
    
    dlib::set_colm(dlib_reye,0) = ((dlib::colm(dlib_reye,0) - dlib_reye_mean[0]) * eye_scaling_x) + dlib_reye_mean[0];
    dlib::set_colm(dlib_reye,1) = ((dlib::colm(dlib_reye,1) - dlib_reye_mean[1]) * eye_scaling_y) + dlib_reye_mean[1];
    
    dlib::set_subm(flattened_2d_landmarks_full_rotated, dlib_leye_range, dlib::range(0,2)) = dlib_leye;
    dlib::set_subm(flattened_2d_landmarks_full_rotated, dlib_reye_range, dlib::range(0,2)) = dlib_reye;
    
    //
    dlib::matrix<long> dlib_nose_range(1,nose_dlib_edge.size());
    for (int i = 0; i < nose_dlib_edge.size(); i++ )
    {
        dlib_nose_range(0,i) = (long)nose_dlib_edge[i];
    }
    dlib::matrix<double> dlib_nose = dlib::subm(flattened_2d_landmarks_full_rotated, dlib_nose_range, dlib::range(0,2));
    
    double dlib_nose_mean[2];
    dlib_nose_mean[0] = dlib_nose(2,0);
    dlib_nose_mean[1] = dlib_nose(2,1);
    
    dlib::set_colm(dlib_nose,0) = ((dlib::colm(dlib_nose,0) - dlib_nose_mean[0]) * nose_scaling_x) + dlib_nose_mean[0];
    dlib::set_colm(dlib_nose,1) = ((dlib::colm(dlib_nose,1) - dlib_nose_mean[1]) * nose_scaling_y) + dlib_nose_mean[1];
    
    dlib::set_subm(flattened_2d_landmarks_full_rotated, dlib_nose_range, dlib::range(0,2)) = dlib_nose;
    //
    
    dlib::matrix<double,68,3> tmp = flattened_2d_landmarks_full_rotated * rotation_matrix;
    dlib::matrix<double, 68,2> _2d_landmarks_full = dlib::subm(tmp, dlib::range(0,67), dlib::range(0,1));
    
    
    dlib::set_colm(_2d_landmarks_full,0) = colm(_2d_landmarks_full,0) + mean_landmarks(0,0);
    dlib::set_colm(_2d_landmarks_full,1) = colm(_2d_landmarks_full,1) + mean_landmarks(0,1);
    PhiPoint * output = (PhiPoint *)malloc(_2d_landmarks_full.nr()*sizeof(PhiPoint));
    for (int row = 0; row < _2d_landmarks_full.nr(); row++)
    {
        output[row] = PhiPoint{
            static_cast<int>(std::round(_2d_landmarks_full(row,0))),
            static_cast<int>(std::round(_2d_landmarks_full(row,1)))
        };
        
    };
    return output;
};

PhiPoint * return_3d_silly_adjusted_warp(int * landmarks_ptr, double * parameters)
{
    // CALLER MUST FREE MEMORY ON RETURN.
    const double eye_scaling_x = 1.2;
    const double eye_scaling_y = 1.7;

    const double mouth_scaling_x = 0.7;
    const double mouth_scaling_y = 0.9;
    
    const double nose_scaling_x = 0.75;
    const double nose_scaling_y = 0.85;
    
    
    dlib::matrix<int, 68, 2> landmarks_i = dlib::mat(landmarks_ptr, 68, 2);
    
    dlib::matrix<double, 68, 2> landmarks = dlib::matrix_cast<double>(landmarks_i);
    
    dlib::matrix<double> mean_landmarks = dlib::rowm(landmarks,30);
    dlib::matrix<double> centered_landmarks = landmarks;
    dlib::set_colm(centered_landmarks,0) = colm(centered_landmarks,0) - mean_landmarks(0,0);
    dlib::set_colm(centered_landmarks,1) = colm(centered_landmarks,1) - mean_landmarks(0,1);
    
    double *dlib_3d = landmarks3d_dlib;
    dlib::matrix<double,68,3> landmarks3d = dlib::mat(dlib_3d, 68, 3);
    dlib::matrix<double> mean_landmarks3d = dlib::rowm(landmarks3d,30);
    dlib::matrix<double> centered_landmarks3d = landmarks3d;
    dlib::set_colm(centered_landmarks3d,0) = colm(centered_landmarks3d,0) - mean_landmarks3d(0,0);
    dlib::set_colm(centered_landmarks3d,1) = colm(centered_landmarks3d,1) - mean_landmarks3d(0,1);
    dlib::set_colm(centered_landmarks3d,2) = colm(centered_landmarks3d,2) - mean_landmarks3d(0,2);
    
    dlib::matrix<double> rotation_matrix = find_overall_rotation_matrix(centered_landmarks, centered_landmarks3d, parameters);
    
    dlib::matrix<double,68,3> flattened_2d_landmarks_full = centered_landmarks3d * rotation_matrix;
    dlib::set_subm(flattened_2d_landmarks_full, dlib::range(0,67), dlib::range(0,1)) = centered_landmarks;
    dlib::matrix<double,68,3> flattened_2d_landmarks_full_rotated = flattened_2d_landmarks_full * dlib::inv(rotation_matrix);
    
    dlib::matrix<long> dlib_leye_range(1,leye_dlib.size());
    for (int i = 0; i < leye_dlib.size(); i++ )
    {
        dlib_leye_range(0,i) = (long)leye_dlib[i];
    }
    dlib::matrix<double> dlib_leye = dlib::subm(flattened_2d_landmarks_full_rotated, dlib_leye_range, dlib::range(0,2));
    
    double dlib_leye_mean[2];
    dlib_leye_mean[0] = dlib::mean(dlib::colm(dlib_leye,0));
    dlib_leye_mean[1] = dlib::mean(dlib::colm(dlib_leye,1));
    
    dlib::set_colm(dlib_leye,0) = ((dlib::colm(dlib_leye,0) - dlib_leye_mean[0]) * eye_scaling_x) + dlib_leye_mean[0];
    dlib::set_colm(dlib_leye,1) = ((dlib::colm(dlib_leye,1) - dlib_leye_mean[1]) * eye_scaling_y) + dlib_leye_mean[1];
    
    dlib::matrix<long> dlib_reye_range(1,reye_dlib.size());
    for (int i = 0; i < reye_dlib.size(); i++ )
    {
        dlib_reye_range(0,i) = (long)reye_dlib[i];
    }
    dlib::matrix<double> dlib_reye = dlib::subm(flattened_2d_landmarks_full_rotated, dlib_reye_range, dlib::range(0,2));
    
    double dlib_reye_mean[2];
    dlib_reye_mean[0] = dlib::mean(dlib::colm(dlib_reye,0));
    dlib_reye_mean[1] = dlib::mean(dlib::colm(dlib_reye,1));
    
    dlib::set_colm(dlib_reye,0) = ((dlib::colm(dlib_reye,0) - dlib_reye_mean[0]) * eye_scaling_x) + dlib_reye_mean[0];
    dlib::set_colm(dlib_reye,1) = ((dlib::colm(dlib_reye,1) - dlib_reye_mean[1]) * eye_scaling_y) + dlib_reye_mean[1];
    
    dlib::set_subm(flattened_2d_landmarks_full_rotated, dlib_leye_range, dlib::range(0,2)) = dlib_leye;
    dlib::set_subm(flattened_2d_landmarks_full_rotated, dlib_reye_range, dlib::range(0,2)) = dlib_reye;
    
    //
    dlib::matrix<long> dlib_mouth_range(1,outermouth_dlib.size());
    for (int i = 0; i < outermouth_dlib.size(); i++ )
    {
        dlib_mouth_range(0,i) = (long)outermouth_dlib[i];
    }
    dlib::matrix<double> dlib_mouth = dlib::subm(flattened_2d_landmarks_full_rotated, dlib_mouth_range, dlib::range(0,2));
    
    double dlib_mouth_mean[2];
    dlib_mouth_mean[0] = dlib::mean(dlib::colm(dlib_mouth,0));
    dlib_mouth_mean[1] = dlib::mean(dlib::colm(dlib_mouth,1));
    
    dlib::set_colm(dlib_mouth,0) = ((dlib::colm(dlib_mouth,0) - dlib_mouth_mean[0]) * mouth_scaling_x) + dlib_mouth_mean[0];
    dlib::set_colm(dlib_mouth,1) = ((dlib::colm(dlib_mouth,1) - dlib_mouth_mean[1]) * mouth_scaling_y) + dlib_mouth_mean[1];
    
    dlib::set_subm(flattened_2d_landmarks_full_rotated, dlib_mouth_range, dlib::range(0,2)) = dlib_mouth;
    //
    dlib::matrix<long> dlib_mouth_inner_range(1,innermouth_dlib.size());
    for (int i = 0; i < innermouth_dlib.size(); i++ )
    {
        dlib_mouth_inner_range(0,i) = (long)innermouth_dlib[i];
    }
    dlib::matrix<double> dlib_mouth_inner = dlib::subm(flattened_2d_landmarks_full_rotated, dlib_mouth_inner_range, dlib::range(0,2));
    
    double dlib_mouth_inner_mean[2];
    dlib_mouth_inner_mean[0] = dlib::mean(dlib::colm(dlib_mouth_inner,0));
    dlib_mouth_inner_mean[1] = dlib::mean(dlib::colm(dlib_mouth_inner,1));
    
    dlib::set_colm(dlib_mouth_inner,0) = ((dlib::colm(dlib_mouth_inner,0) - dlib_mouth_inner_mean[0]) * mouth_scaling_x) + dlib_mouth_inner_mean[0];
    dlib::set_colm(dlib_mouth_inner,1) = ((dlib::colm(dlib_mouth_inner,1) - dlib_mouth_inner_mean[1]) * mouth_scaling_y) + dlib_mouth_inner_mean[1];
    
    dlib::set_subm(flattened_2d_landmarks_full_rotated, dlib_mouth_inner_range, dlib::range(0,2)) = dlib_mouth_inner;
    
    //
    dlib::matrix<long> dlib_nose_range(1,nose_dlib_edge.size());
    for (int i = 0; i < nose_dlib_edge.size(); i++ )
    {
        dlib_nose_range(0,i) = (long)nose_dlib_edge[i];
    }
    dlib::matrix<double> dlib_nose = dlib::subm(flattened_2d_landmarks_full_rotated, dlib_nose_range, dlib::range(0,2));
    
    double dlib_nose_mean[2];
    dlib_nose_mean[0] = dlib_nose(2,0);
    dlib_nose_mean[1] = dlib_nose(2,1);
    
    dlib::set_colm(dlib_nose,0) = ((dlib::colm(dlib_nose,0) - dlib_nose_mean[0]) * nose_scaling_x) + dlib_nose_mean[0];
    dlib::set_colm(dlib_nose,1) = ((dlib::colm(dlib_nose,1) - dlib_nose_mean[1]) * nose_scaling_y) + dlib_nose_mean[1];
    
    dlib::set_subm(flattened_2d_landmarks_full_rotated, dlib_nose_range, dlib::range(0,2)) = dlib_nose;
    //
    
    dlib::matrix<double,68,3> tmp = flattened_2d_landmarks_full_rotated * rotation_matrix;
    dlib::matrix<double, 68,2> _2d_landmarks_full = dlib::subm(tmp, dlib::range(0,67), dlib::range(0,1));
    
    
    dlib::set_colm(_2d_landmarks_full,0) = colm(_2d_landmarks_full,0) + mean_landmarks(0,0);
    dlib::set_colm(_2d_landmarks_full,1) = colm(_2d_landmarks_full,1) + mean_landmarks(0,1);
    PhiPoint * output = (PhiPoint *)malloc(_2d_landmarks_full.nr()*sizeof(PhiPoint));
    for (int row = 0; row < _2d_landmarks_full.nr(); row++)
    {
        output[row] = PhiPoint{
            static_cast<int>(std::round(_2d_landmarks_full(row,0))),
            static_cast<int>(std::round(_2d_landmarks_full(row,1)))
        };
        
    };
    return output;
};

// Needs c linkage to be imported to Swift
extern "C" {
PhiPoint * adjusted_warp(PhiPoint * landmarks, PhiPoint * face_flat_warp, double * parameters)
{
    // CALLER MUST FREE MEMORY ON RETURN.
    PhiPoint * adjusted_warp = return_3d_adjusted_warp((int *)landmarks, (int *)face_flat_warp, parameters);
    return adjusted_warp;
}
}

extern "C" {
PhiPoint * attractive_adjusted_warp(PhiPoint * landmarks, double * parameters)
{
    // CALLER MUST FREE MEMORY ON RETURN.
    PhiPoint * adjusted_warp = return_3d_attractive_adjusted_warp((int *)landmarks, parameters);
    return adjusted_warp;
}
}

extern "C" {
    PhiPoint * attractive_adjusted_warp2(PhiPoint * landmarks, double * parameters)
    {
        // CALLER MUST FREE MEMORY ON RETURN.
        PhiPoint * adjusted_warp = return_3d_attractive_adjusted_warp2((int *)landmarks, parameters);
        return adjusted_warp;
    }
}

extern "C" {
PhiPoint * silly_adjusted_warp(PhiPoint * landmarks, double * parameters)
{
    // CALLER MUST FREE MEMORY ON RETURN.
    PhiPoint * adjusted_warp = return_3d_silly_adjusted_warp((int *)landmarks, parameters);
    return adjusted_warp;
}
}

