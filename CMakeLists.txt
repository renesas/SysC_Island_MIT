cmake_minimum_required(VERSION 3.14)
project(SysC_Island_MIT LANGUAGES CXX)

set (CMAKE_CXX_STANDARD 17)

##############################################
# Defines, variables
##############################################
set(PROJECT_UTILS_PATH ${PROJECT_SOURCE_DIR}/utils)
set(SYSIC_INCLUDE_PATH ${PROJECT_SOURCE_DIR}/include)
# set(RQ_UTILS_PATH ${PROJECT_SOURCE_DIR}/utils)
set(INSTALL_DIR "prebuilt_x86_64")


#########################################
# PACKAGE PREFIX PATH (3rd party libs)
#########################################
list(APPEND CMAKE_PREFIX_PATH
    ${PROJECT_UTILS_PATH}/${INSTALL_DIR}/lib/cmake/RapidJSON
    ${PROJECT_UTILS_PATH}/${INSTALL_DIR}/lib/cmake/base-components-1.0
    ${PROJECT_UTILS_PATH}/${INSTALL_DIR}/lib/cmake/SystemCLanguage
    ${PROJECT_UTILS_PATH}/${INSTALL_DIR}/lib/cmake/SystemCCCI
    ${PROJECT_UTILS_PATH}/${INSTALL_DIR}/lib/cmake/gsutils-1.0
    ${PROJECT_UTILS_PATH}/${INSTALL_DIR}/lib/cmake/gssync-1.0
    ${PROJECT_UTILS_PATH}/${INSTALL_DIR}/lib/cmake/mwr
    ${PROJECT_UTILS_PATH}/${INSTALL_DIR}/lib/cmake/vcml
    ${PROJECT_UTILS_PATH}/${INSTALL_DIR}/lib/cmake/vcml-cci
)

#########################################
# FIND PACKAGES
#########################################

find_package(gssync CONFIG REQUIRED)
find_package(vcml CONFIG REQUIRED)
find_package(vcml-cci CONFIG REQUIRED)
find_package(SDL2 CONFIG REQUIRED)
find_package(base-components CONFIG REQUIRED)

add_subdirectory(Package/REMOTEPORT)

set(TARGET_LINK_LIBRARIES
    SystemC_model::REMOTEPORT
    vcml-cci
	SystemC::systemc
    GreenSocs::base-components
    GreenSocs::gssync
    vcml
)

#########################################
# SYSTEMC PREBUILT PATH
#########################################
set(SystemC_INCLUDE_DIRS ${PROJECT_UTILS_PATH}/prebuilt_x86_64/include)

#########################################
# EXECUTABLE
#########################################
add_executable(vp
    ${PROJECT_SOURCE_DIR}/src/main.cpp
    ${PROJECT_SOURCE_DIR}/src/SysC_Island_MIT.cpp
    ${PROJECT_SOURCE_DIR}/src/Memory.cpp
)

target_compile_options(vp PUBLIC -fPIC)


target_include_directories(vp PUBLIC
    ${SYSIC_INCLUDE_PATH}
    ${PROJECT_UTILS_PATH}
    ${PROJECT_SOURCE_DIR}/Package/REMOTEPORT
    # ${RQ_UTILS_PATH}
)

target_link_libraries(vp PUBLIC
    "${TARGET_LINK_LIBRARIES}"
)

install (TARGETS vp DESTINATION ${CMAKE_INSTALL_BINDIR})




# Cleanup
unset(TARGET_INCLUDE_DIRECTORIES CACHE)
unset(TARGET_LINK_LIBRARIES CACHE)


