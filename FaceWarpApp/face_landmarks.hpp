#ifndef face_landmarks_hpp
#define face_landmarks_hpp

// Global index sets

#include <dlib/matrix/matrix.h>

std::vector<int> face_dlib {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};
std::vector<int> face_half_dlib {0, 1, 2, 3, 4, 5, 6, 7, 8};
std::vector<int> leyebrow_dlib {17, 18, 19, 20, 21};
std::vector<int> reyebrow_dlib {22, 23, 24, 25, 26};
std::vector<int> nose_dlib {27, 28, 29, 30, 31, 32, 33, 34, 35};
std::vector<int> nose_dlib_edge {31, 32, 33, 34, 35};
std::vector<int> leye_dlib {36, 37, 38, 39, 40, 41};
std::vector<int> leye_dlib_mid {37, 38, 39, 41};
std::vector<int> reye_dlib {42, 43, 44, 45, 46, 47};
std::vector<int> reye_dlib_mid {43, 44, 45, 47};
std::vector<int> outermouth_dlib {48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59};
std::vector<int> innermouth_dlib {60, 61, 62, 63, 64, 65, 66, 67};
std::vector<int> total_mouth {48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67};


std::vector<int> dlib_total {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51,52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68};

std::vector<int> dlib_face_outline {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26};

std::vector<int> dlib_not_face_outline {27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51,52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68};//std::vector<int> dlib_face_outline {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 26,25,24,23,22,21,20,19,18,17};

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

std::vector<int> trn_total {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,48, 49, 50, 51,52, 53, 5, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68};
std::vector<int> trn_face_outline {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26};

std::vector<int> exchange_list_nose_warp {27, 28, 29, 30, 31, 32, 33, 34, 35};
// exchange_list_chin_warp = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14};
// exchange_list_nose_chin_warp = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 27, 28, 29, 30, 31, 32, 33, 34, 35};
std::vector<int> exchange_list_chin_warp {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,16};
std::vector<int> exchange_list_nose_chin_warp {0,1,2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,16, 27, 28, 29, 30, 31, 32, 33, 34, 35};


std::vector<std::vector<int>> triangles {{ 0, 36, 17},{36, 18, 17},{36, 37, 18},{37, 19, 18},{37, 38, 19},{38, 20, 19},{38, 39, 20},{39, 21, 20},{36, 41, 37},{41, 40, 37},{40, 38, 37},{40, 39, 38},{39, 27, 21},{27, 22, 21},{27, 42, 22},{42, 23, 22},{42, 43, 23},{43, 24, 23},{43, 44, 24},{44, 25, 24},{44, 45, 25},{45, 26, 25},{45, 16, 26},{42, 47, 43},{47, 44, 43},{47, 46, 44},{46, 45, 44},{39, 28, 27},{28, 42, 27},{32, 33, 30},{33, 34, 30},{31, 30, 32},{31, 30, 29},{34, 35, 30},{35, 29, 30},{35, 28, 29},{31, 29, 28},{ 0,  1, 36},{39, 31, 28},{35, 42, 28},{15, 16, 45},{40, 31, 39},{35, 47, 42},{ 1, 41, 36},{ 1, 40, 41},{15, 45, 46},{15, 46, 47},{35, 15, 47},{ 1, 31, 40},{ 1,  2, 31},{35, 14, 15},{ 2, 48, 31},{ 3, 48,  2},{ 4, 48,  3},{54, 14, 35},{54, 13, 14},{12, 13, 54},{ 4,  5, 48},{ 5, 59, 48},{11, 12, 54},{55, 11, 54},{10, 11, 55},{56, 10, 55},{ 9, 10, 56},{ 5,  6, 59},{ 6, 58, 59},{ 6,  7, 58},{ 7, 57, 58},{ 7,  8, 57},{57,  9, 56},{ 8,  9, 57},{48, 49, 31},{53, 54, 35},{49, 50, 31},{52, 53, 35},{50, 32, 31},{52, 35, 34},{50, 51, 32},{51, 52, 34},{51, 34, 33},{51, 33, 32},{48, 60, 49},{59, 60, 48},{60, 67, 61},{64, 54, 53},{55, 54, 64},{65, 64, 63},{67, 62, 61},{65, 63, 62},{67, 66, 62},{66, 65, 62},{51, 52, 63},{61, 62, 51},{60, 61, 49},{61, 50, 49},{63, 64, 53},{63, 53, 52},{61, 51, 50},{51, 62, 63},{59, 67, 60},{59, 58, 67},{58, 57, 67},{57, 66, 67},{57, 65, 66},{57, 56, 65},{65, 55, 56},{55, 64, 65}};


double landmarks3d_female[] = { -62.628125  , -33.59077819, -55.594156  ,-60.91822917, -17.02775735, -54.961081  ,-57.575     ,  -0.88400735, -54.144952  ,-53.85260417,  14.86963848, -54.082354  ,-47.95      ,  29.74099265, -51.05739   ,-38.4890625 ,  42.68734681, -41.691635  ,-26.30104167,  53.67224265, -33.880245  ,-12.2609375 ,  62.36755515, -24.827777  ,  2.9640625 ,  64.50765931, -19.984808  , 17.94479167,  61.30661765, -25.857057  , 31.62760417,  52.09724265, -35.26741   , 43.39635417,  40.75870098, -44.25428   , 52.44166667,  27.31651348, -54.58913   , 57.70260417,  11.94932598, -58.370838  , 60.50260417,  -4.38765319, -59.234532  , 62.87239583, -20.89234069, -57.75897   , 63.77291667, -37.66317402, -55.926353  ,-54.00208333, -45.86265319, -50.837638  ,-45.67135417, -52.36681985, -37.756241  ,-34.56614583, -53.79963235, -28.404848  ,-23.39895833, -52.03869485, -22.972162  ,-12.665625  , -47.76577819, -21.823729  ,  9.80364583, -48.90327819, -21.930193  , 20.6390625 , -53.97827819, -23.432147  , 31.99583333, -56.53765319, -30.122401  , 43.5640625 , -55.64077819, -43.517617  , 52.696875  , -49.77463235, -62.32787   , -0.84947917, -35.31161152, -21.588371  , -0.56875   , -24.33400735, -15.323445  , -0.3171875 , -13.35275735,  -6.85443   ,  0.0,  -2.33140319,   0.0,-10.2375    ,   5.65661765, -20.414374  , -4.99114583,   7.39568015, -16.601973  ,  0.546875  ,   8.86859681, -11.468503  ,  6.0375    ,   6.93995098, -16.690475  , 11.20364583,   4.85453431, -20.708989  ,-40.89166667, -32.77775735, -44.053835  ,-33.7421875 , -37.44442402, -36.141291  ,-24.740625  , -37.28765319, -33.371531  ,-17.31041667, -31.10067402, -36.650995  ,-25.37864583, -29.25588235, -35.946757  ,-34.27447917, -29.17931985, -37.552786  , 16.52291667, -32.36213235, -36.667505  , 23.73802083, -39.08504902, -32.794067  , 32.65208333, -39.70484069, -35.78653   , 39.9546875 , -35.49754902, -45.73107   , 33.753125  , -31.58556985, -38.961779  , 24.90104167, -31.06421569, -35.695715  ,-21.52864583,  26.13526348, -27.967124  ,-12.96458333,  21.45401348, -19.569126  , -4.74322917,  18.60661765, -13.498111  ,  0.99895833,  20.06495098, -12.178859  ,  7.00364583,  18.27849265, -13.492352  , 15.4328125 ,  20.61547181, -19.488487  , 24.303125  ,  24.44724265, -28.208657  , 16.19114583,  32.74515931, -23.077874  ,  8.05364583,  36.72640931, -16.793171  ,  1.50572917,  37.60870098, -16.393677  , -4.87447917,  37.18943015, -17.521476  ,-13.13958333,  33.97745098, -23.837728  ,-17.2046875 ,  26.54724265, -26.004197  , -4.71770833,  25.57380515, -18.031916  ,  1.16302083,  25.78161765, -17.122875  ,  7.2734375 ,  25.18005515, -17.8596    , 19.99739583,  25.16182598, -26.339691  ,  7.43020833,  27.03578431, -18.34822   ,  1.21041667,  27.95088848, -16.863275  , -4.73229167,  27.45140931, -18.512848  };


double landmarks3d_male[] = { -62.68651938, -37.05565618, -55.594156  ,-61.02648266, -20.1016878 , -54.961081  ,-58.08334471,  -3.10928564, -54.144952  ,-55.10285183,  13.85542034, -54.082354  ,-49.66664109,  29.7418647 , -51.05739   ,-39.98588422,  43.47135606, -41.691635  ,-27.6063528 ,  54.70532934, -33.880245  ,-14.61533307,  64.12523944, -24.827777  ,  1.26173906,  67.19963894, -19.984808  , 17.10835456,  64.23502839, -25.857057  , 30.00051939,  54.18277264, -35.26741   , 42.24385163,  42.87965292, -44.25428   , 51.99698848,  29.58774219, -54.58913   , 56.93712072,  13.92607381, -58.370838  , 60.45823466,  -2.9103011 , -59.234532  , 63.20736804, -19.05066473, -57.75897   , 63.35368062, -35.2407459 , -55.926353  ,-53.76771236, -44.16225929, -50.837638  ,-46.53639272, -52.24451703, -37.756241  ,-34.67811439, -54.72646106, -28.404848  ,-22.69827263, -52.35035159, -22.972162  ,-10.53237583, -48.25662027, -21.823729  ,  9.51312958, -48.3961481 , -21.930193  , 22.57598812, -52.51337025, -23.432147  , 35.21409095, -54.33645592, -30.122401  , 47.46614308, -51.42000996, -43.517617  , 56.03714063, -43.79542619, -62.32787   ,  0.27639959, -36.72416476, -21.588371  , -0.20026789, -25.23733215, -15.323445  , -0.13105949, -14.2788693 ,  -6.85443   ,  0.0 ,  -2.12921875,   0.0 ,-12.66404564,   4.29004183, -20.414374  , -6.41918013,   6.46429869, -16.601973  , -0.24019738,   8.68740321, -11.468503  ,  6.50927453,   6.77638962, -16.690475  , 13.19888197,   4.90976153, -20.708989  ,-39.99789292, -36.06193949, -44.053835  ,-32.57346666, -39.95771132, -36.141291  ,-23.66473366, -39.63456822, -33.371531  ,-15.82941448, -33.93862039, -36.650995  ,-24.29239832, -32.24180363, -35.946757  ,-33.26830847, -31.89661627, -37.552786  , 17.13564272, -33.7594564 , -36.667505  , 24.78854513, -39.68019728, -32.794067  , 33.98402148, -39.56965524, -35.78653   , 40.87667467, -35.40159737, -45.73107   , 34.6785083 , -32.16741002, -38.961779  , 25.46937913, -32.2678294 , -35.695715  ,-22.9472063 ,  25.64448529, -27.967124  ,-14.27312978,  23.04899509, -19.569126  , -6.78473029,  20.96136063, -13.498111  , -0.41591365,  23.04371601, -12.178859  ,  6.78522224,  21.29270756, -13.492352  , 15.45675869,  23.15240147, -19.488487  , 24.25481132,  25.53681515, -28.208657  , 15.5170659 ,  31.14848778, -23.077874  ,  7.4044824 ,  34.31743608, -16.793171  ,  0.25807301,  35.40934539, -16.393677  , -6.784795  ,  34.56891644, -17.521476  ,-14.18798096,  31.64518608, -23.837728  ,-19.17711096,  26.43703746, -26.004197  , -6.64112082,  26.42159155, -18.031916  , -0.23361884,  27.23821815, -17.122875  ,  7.57606636,  26.14941796, -17.8596    , 20.92196457,  26.15200236, -26.339691  ,  6.94509224,  26.74088238, -18.34822   , -0.25542502,  27.87290906, -16.863275  , -6.61683871,  26.40358798, -18.512848 } ;


std::vector<std::vector<float>> landmarks3d {{-62.65732219, -35.32321718, -55.594156  },{-60.97235592, -18.56472258, -54.961081  },{-57.82917236,  -1.99664649, -54.144952  },{-54.477728  ,  14.36252941, -54.082354  },{-48.80832055,  29.74142867, -51.05739   },{-39.23747336,  43.07935144, -41.691635  },{-26.95369724,  54.18878599, -33.880245  },{-13.43813528,  63.2463973 , -24.827777  },{  2.11290078,  65.85364913, -19.984808  },{ 17.52657312,  62.77082302, -25.857057  },{ 30.81406178,  53.14000764, -35.26741   },{ 42.8201029 ,  41.81917695, -44.25428   },{ 52.21932758,  28.45212784, -54.58913   },{ 57.31986244,  12.9376999 , -58.370838  },{ 60.48041941,  -3.64897715, -59.234532  },{ 63.03988194, -19.97150271, -57.75897   },{ 63.56329864, -36.45195996, -55.926353  },{-53.88489785, -45.01245624, -50.837638  },{-46.10387344, -52.30566844, -37.756241  },{-34.62213011, -54.26304671, -28.404848  },{-23.04861548, -52.19452322, -22.972162  },{-11.59900042, -48.01119923, -21.823729  },{  9.65838771, -48.64971314, -21.930193  },{ 21.60752531, -53.24582422, -23.432147  },{ 33.60496214, -55.43705455, -30.122401  },{ 45.51510279, -53.53039407, -43.517617  },{ 54.36700781, -46.78502927, -62.32787   },{ -0.28653979, -36.01788814, -21.588371  },{ -0.38450894, -24.78566975, -15.323445  },{ -0.2241235 , -13.81581333,  -6.85443   },{  0.0 ,  -2.23031097,   0.0 },{-11.45077282,   4.97332974, -20.414374  },{ -5.70516298,   6.92998942, -16.601973  },{  0.15333881,   8.77800001, -11.468503  },{  6.27338726,   6.8581703 , -16.690475  },{ 12.2012639 ,   4.88214792, -20.708989  },{-40.4447798 , -34.41984842, -44.053835  },{-33.15782708, -38.70106767, -36.141291  },{-24.20267933, -38.4611107 , -33.371531  },{-16.56991557, -32.5196472 , -36.650995  },{-24.83552208, -30.74884299, -35.946757  },{-33.77139382, -30.53796806, -37.552786  },{ 16.82927969, -33.06079438, -36.667505  },{ 24.26328298, -39.38262315, -32.794067  },{ 33.31805241, -39.63724796, -35.78653   },{ 40.41568108, -35.44957319, -45.73107   },{ 34.21581665, -31.87648994, -38.961779  },{ 25.1852104 , -31.66602254, -35.695715  },{-22.23792606,  25.88987439, -27.967124  },{-13.61885656,  22.25150429, -19.569126  },{ -5.76397973,  19.78398914, -13.498111  },{  0.29152234,  21.55433349, -12.178859  },{  6.89443404,  19.7856001 , -13.492352  },{ 15.4447856 ,  21.88393664, -19.488487  },{ 24.27896816,  24.9920289 , -28.208657  },{ 15.85410587,  31.94682354, -23.077874  },{  7.72906412,  35.5219227 , -16.793171  },{  0.88190109,  36.50902319, -16.393677  },{ -5.82963709,  35.87917329, -17.521476  },{-13.66378214,  32.81131853, -23.837728  },{-18.19089923,  26.49214005, -26.004197  },{ -5.67941458,  25.99769835, -18.031916  },{  0.464701  ,  26.5099179 , -17.122875  },{  7.42475193,  25.66473655, -17.8596    },{ 20.4596802 ,  25.65691417, -26.339691  },{  7.18765029,  26.88833334, -18.34822   },{  0.47749582,  27.91189877, -16.863275  },{ -5.67456519,  26.92749865, -18.512848  }};



double landmarks3d_dlib[] = {-62.65732219, -35.32321718, -55.594156, -60.97235592, -18.56472258, -54.961081, -57.82917236, -1.99664649, -54.144952, -54.477728, 14.36252941,  -54.082354, -48.80832055, 29.74142867, -51.05739, -39.23747336, 43.07935144, -41.691635, -26.95369724, 54.18878599, -33.880245, -13.43813528, 63.2463973, -24.827777, 2.11290078, 65.85364913, -19.984808, 17.52657312, 62.77082302, -25.857057, 30.81406178, 53.14000764, -35.26741, 42.8201029, 41.81917695, -44.25428, 52.21932758, 28.45212784, -54.58913, 57.31986244, 12.9376999, -58.370838, 60.48041941, -3.64897715, -59.234532, 63.03988194, -19.97150271, -57.75897, 63.56329864, -36.45195996, -55.926353, -53.88489785, -45.01245624, -50.837638, -46.10387344, -52.30566844, -37.756241, -34.62213011, -54.26304671, -28.404848, -23.04861548, -52.19452322, -22.972162, -11.59900042, -48.01119923, -21.823729, 9.65838771, -48.64971314, -21.930193, 21.60752531, -53.24582422, -23.432147, 33.60496214, -55.43705455, -30.122401, 45.51510279, -53.53039407, -43.517617, 54.36700781, -46.78502927, -62.32787, -0.28653979, -36.01788814, -21.588371, -0.38450894, -24.78566975, -15.323445, -0.2241235, -13.81581333, -6.85443, 0.0, -2.23031097, 0.0, -11.45077282, 4.97332974, -20.414374, -5.70516298, 6.92998942, -16.601973, 0.15333881, 8.77800001, -11.468503, 6.27338726, 6.8581703, -16.690475, 12.2012639, 4.88214792, -20.708989, -40.4447798, -34.41984842, -44.053835, -33.15782708, -38.70106767, -36.141291, -24.20267933, -38.4611107, -33.371531, -16.56991557, -32.5196472, -36.650995, -24.83552208, -30.74884299, -35.946757, -33.77139382, -30.53796806, -37.552786, 16.82927969, -33.06079438, -36.667505, 24.26328298, -39.38262315, -32.794067, 33.31805241, -39.63724796, -35.78653, 40.41568108, -35.44957319, -45.73107, 34.21581665, -31.87648994, -38.961779, 25.1852104, -31.66602254, -35.695715, -22.23792606, 25.88987439, -27.967124, -13.61885656, 22.25150429, -19.569126, -5.76397973, 19.78398914, -13.498111, 0.29152234, 21.55433349, -12.178859, 6.89443404, 19.7856001, -13.492352, 15.4447856, 21.88393664, -19.488487, 24.27896816, 24.9920289, -28.208657, 15.85410587, 31.94682354, -23.077874, 7.72906412, 35.5219227, -16.793171, 0.88190109, 36.50902319, -16.393677, -5.82963709, 35.87917329, -17.521476, -13.66378214, 32.81131853, -23.837728, -18.19089923, 26.49214005, -26.004197, -5.67941458, 25.99769835, -18.031916, 0.464701, 26.5099179, -17.122875, 7.42475193, 25.66473655, -17.8596, 20.4596802, 25.65691417, -26.339691, 7.18765029, 26.88833334, -18.34822, 0.47749582, 27.91189877, -16.863275, -5.67456519, 26.92749865, -18.512848};


std::vector<std::vector<float>> landmarks_faceflat {{-62.65732219, -35.32321718},{-60.97235592, -18.56472258},{-57.82917236,  -1.99664649},{-54.477728  ,  14.36252941},{-48.80832055,  29.74142867},{-39.23747336,  43.07935144},{-26.95369724,  54.18878599},{-13.43813528,  63.2463973 },{  2.11290078,  65.85364913},{ 17.52657312,  62.77082302},{ 30.81406178,  53.14000764},{ 42.8201029 ,  41.81917695},{ 52.21932758,  28.45212784},{ 57.31986244,  12.9376999 },{ 60.48041941,  -3.64897715},{ 63.03988194, -19.97150271},{ 63.56329864, -36.45195996},{-53.88489785, -45.01245624},{-46.10387344, -52.30566844},{-34.62213011, -54.26304671},{-23.04861548, -52.19452322},{-11.59900042, -48.01119923},{  9.65838771, -48.64971314},{ 21.60752531, -53.24582422},{ 33.60496214, -55.43705455},{ 45.51510279, -53.53039407},{ 54.36700781, -46.78502927},{ -0.28653979, -36.01788814},{ -0.38450894, -24.78566975},{ -0.2241235 , -13.81581333},{  0.0 ,  -2.23},{-11.45077282,   4.97332974},{ -5.70516298,   6.92998942},{  0.15333881,   8.77800001},{  6.27338726,   6.8581703 },{ 12.2012639 ,   4.88214792},{-40.4447798 , -34.41984842},{-33.15782708, -38.70106767},{-24.20267933, -38.4611107 },{-16.56991557, -32.5196472 },{-24.83552208, -30.74884299},{-33.77139382, -30.53796806},{ 16.82927969, -33.06079438},{ 24.26328298, -39.38262315},{ 33.31805241, -39.63724796},{ 40.41568108, -35.44957319},{ 34.21581665, -31.87648994},{ 25.1852104 , -31.66602254},{-22.23792606,  25.88987439},{-13.61885656,  22.25150429},{ -5.76397973,  19.78398914},{  0.29152234,  21.55433349},{  6.89443404,  19.7856001 },{ 15.4447856 ,  21.88393664},{ 24.27896816,  24.9920289 },{ 15.85410587,  31.94682354},{  7.72906412,  35.5219227 },{  0.88190109,  36.50902319},{ -5.82963709,  35.87917329},{-13.66378214,  32.81131853},{-18.19089923,  26.49214005},{ -5.67941458,  25.99769835},{  0.464701  ,  26.5099179 },{  7.42475193,  25.66473655},{ 20.4596802 ,  25.65691417},{  7.18765029,  26.88833334},{  0.47749582,  27.91189877},{ -5.67456519,  26.92749865}};

double landmarks_faceflat_dlib[136] = {-62.65732219, -35.32321718,-60.97235592, -18.56472258,-57.82917236,  -1.99664649,-54.477728  ,  14.36252941,-48.80832055,  29.74142867,-39.23747336,  43.07935144,-26.95369724,  54.18878599,-13.43813528,  63.2463973 ,  2.11290078,  65.85364913, 17.52657312,  62.77082302, 30.81406178,  53.14000764, 42.8201029 ,  41.81917695, 52.21932758,  28.45212784, 57.31986244,  12.9376999 , 60.48041941,  -3.64897715, 63.03988194, -19.97150271, 63.56329864, -36.45195996,-53.88489785, -45.01245624,-46.10387344, -52.30566844,-34.62213011, -54.26304671,-23.04861548, -52.19452322,-11.59900042, -48.01119923,  9.65838771, -48.64971314, 21.60752531, -53.24582422, 33.60496214, -55.43705455, 45.51510279, -53.53039407, 54.36700781, -46.78502927, -0.28653979, -36.01788814, -0.38450894, -24.78566975, -0.2241235 , -13.81581333,  0.0 ,  -2.23,-11.45077282,   4.97332974, -5.70516298,   6.92998942,  0.15333881,   8.77800001,  6.27338726,   6.8581703 , 12.2012639 ,   4.88214792,-40.4447798 , -34.41984842,-33.15782708, -38.70106767,-24.20267933, -38.4611107 ,-16.56991557, -32.5196472 ,-24.83552208, -30.74884299,-33.77139382, -30.53796806, 16.82927969, -33.06079438, 24.26328298, -39.38262315, 33.31805241, -39.63724796, 40.41568108, -35.44957319, 34.21581665, -31.87648994, 25.1852104 , -31.66602254,-22.23792606,  25.88987439,-13.61885656,  22.25150429, -5.76397973,  19.78398914,  0.29152234,  21.55433349,  6.89443404,  19.7856001 , 15.4447856 ,  21.88393664, 24.27896816,  24.9920289 , 15.85410587,  31.94682354,  7.72906412,  35.5219227 ,  0.88190109,  36.50902319, -5.82963709,  35.87917329,-13.66378214,  32.81131853,-18.19089923,  26.49214005, -5.67941458,  25.99769835,  0.464701  ,  26.5099179 ,  7.42475193,  25.66473655, 20.4596802 ,  25.65691417,  7.18765029,  26.88833334,  0.47749582,  27.91189877, -5.67456519,  26.92749865};

int fifty_twenty_mouth[] =  {-25,0,-25,10,0,10,25,10,25,0,25,-10,0,-10,-25,-10};


#endif