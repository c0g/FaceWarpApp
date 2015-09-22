#ifndef face_landmarks_hpp
#define face_landmarks_hpp

// Global index sets

std::vector<int> face_dlib {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};
std::vector<int> face_half_dlib {0, 1, 2, 3, 4, 5, 6, 7, 8};
std::vector<int> leyebrow_dlib {17, 18, 19, 20, 21};
std::vector<int> reyebrow_dlib {22, 23, 24, 25, 26};
std::vector<int> nose_dlib {27, 28, 29, 30, 31, 32, 33, 34, 35};
std::vector<int> leye_dlib {36, 37, 38, 39, 40, 41};
std::vector<int> leye_dlib_mid {37, 38, 39, 41};
std::vector<int> reye_dlib {42, 43, 44, 45, 46, 47};
std::vector<int> reye_dlib_mid {43, 44, 45, 47};
std::vector<int> outermouth_dlib {48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59};
std::vector<int> innermouth_dlib {60, 61, 62, 63, 64, 65, 66, 67, 68};


std::vector< std::vector<int> > dlib_total {face_dlib, leyebrow_dlib, reyebrow_dlib,
    nose_dlib, leye_dlib, reye_dlib, outermouth_dlib, innermouth_dlib};
std::vector< std::vector<int> > dlib_face_outline {face_dlib, leyebrow_dlib, reyebrow_dlib};

std::vector<int> face_trn = face_dlib;
std::vector<int> face_half_trn = face_half_dlib;
std::vector<int> leyebrow_trn = leyebrow_dlib;
std::vector<int> reyebrow_trn = reyebrow_dlib;
std::vector<int> nose_trn = nose_dlib;
std::vector<int> leye_trn = leye_dlib;
std::vector<int> leye_trn_mid = leye_dlib_mid;
std::vector<int> reye_trn = reye_dlib;
std::vector<int> reye_trn_mid = reye_dlib_mid;
std::vector<int> outermouth_trn = outermouth_dlib;
std::vector<int> innermouth_trn = innermouth_dlib;

std::vector< std::vector<int> > trn_total {face_trn, leyebrow_trn, reyebrow_trn,
    nose_trn, leye_trn, reye_trn, outermouth_trn, innermouth_trn};
std::vector< std::vector<int> > trn_face_outline {face_trn, leyebrow_trn, reyebrow_trn};

std::vector<int> exchange_list_nose_warp {27, 28, 29, 30, 31, 32, 33, 34, 35};
// exchange_list_chin_warp = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14};
// exchange_list_nose_chin_warp = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 27, 28, 29, 30, 31, 32, 33, 34, 35};
std::vector<int> exchange_list_chin_warp {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,16};
std::vector<int> exchange_list_nose_chin_warp {0,1,2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,16, 27, 28, 29, 30, 31, 32, 33, 34, 35};

#endif
