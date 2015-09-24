# Install script for directory: /Users/tbgunter/anaconda/conda-bld/work/dlib-18.16/tools/python

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/tbgunter/anaconda/conda-bld/work/dlib-18.16/tools/python/../../python_examples/dlib.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/Users/tbgunter/anaconda/conda-bld/work/dlib-18.16/tools/python/../../python_examples" TYPE SHARED_LIBRARY FILES "/Users/tbgunter/anaconda/conda-bld/work/dlib-18.16/build/dlib.so")
  if(EXISTS "$ENV{DESTDIR}/Users/tbgunter/anaconda/conda-bld/work/dlib-18.16/tools/python/../../python_examples/dlib.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/Users/tbgunter/anaconda/conda-bld/work/dlib-18.16/tools/python/../../python_examples/dlib.so")
    execute_process(COMMAND /usr/bin/install_name_tool
      -delete_rpath "/Users/tbgunter/anaconda/envs/_build/lib"
      "$ENV{DESTDIR}/Users/tbgunter/anaconda/conda-bld/work/dlib-18.16/tools/python/../../python_examples/dlib.so")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}/Users/tbgunter/anaconda/conda-bld/work/dlib-18.16/tools/python/../../python_examples/dlib.so")
    endif()
  endif()
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/Users/tbgunter/anaconda/conda-bld/work/dlib-18.16/build/dlib_build/cmake_install.cmake")

endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

file(WRITE "/Users/tbgunter/anaconda/conda-bld/work/dlib-18.16/build/${CMAKE_INSTALL_MANIFEST}" "")
foreach(file ${CMAKE_INSTALL_MANIFEST_FILES})
  file(APPEND "/Users/tbgunter/anaconda/conda-bld/work/dlib-18.16/build/${CMAKE_INSTALL_MANIFEST}" "${file}\n")
endforeach()
