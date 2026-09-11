cmake_minimum_required(VERSION 3.14)
project(utils VERSION 1.0)

set(CMAKE_CXX_STANDARD 17)

set(PROJECT_UTILS_PATH ${PROJECT_SOURCE_DIR})
include(common_package.cmake)

add_subdirectory(Packages)