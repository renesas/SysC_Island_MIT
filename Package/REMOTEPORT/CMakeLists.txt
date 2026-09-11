cmake_minimum_required(VERSION 3.14)
project(REMOTEPORT LANGUAGES CXX C)

set(PROJECT_UTILS_PATH ${PROJECT_UTILS_PATH}/)

link_libraries(
    SystemC::systemc
    mwr
    vcml
)

include_directories(
    ${PROJECT_UTILS_PATH}/libsystemctlm-soc
    ${PROJECT_UTILS_PATH}/libsystemctlm-soc/libremote-port
)

add_library(ZYNQ STATIC 
    ${PROJECT_UTILS_PATH}/libsystemctlm-soc/libremote-port/remote-port-tlm.cc
    ${PROJECT_UTILS_PATH}/libsystemctlm-soc/libremote-port/remote-port-tlm-memory-master.cc
    ${PROJECT_UTILS_PATH}/libsystemctlm-soc/libremote-port/remote-port-tlm-memory-slave.cc
    ${PROJECT_UTILS_PATH}/libsystemctlm-soc/libremote-port/remote-port-tlm-wires.cc
    ${PROJECT_UTILS_PATH}/libsystemctlm-soc/libremote-port/remote-port-tlm-ats.cc
    ${PROJECT_UTILS_PATH}/libsystemctlm-soc/libremote-port/remote-port-proto.c
    ${PROJECT_UTILS_PATH}/libsystemctlm-soc/libremote-port/remote-port-tlm-pci-ep.cc
    ${PROJECT_UTILS_PATH}/libsystemctlm-soc/libremote-port/remote-port-sk.c
    ${PROJECT_UTILS_PATH}/libsystemctlm-soc/libremote-port/safeio.c
)

add_library(${PROJECT_NAME} STATIC
    ${CMAKE_CURRENT_SOURCE_DIR}/src/REMOTEPORT.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/REMOTEPORT.h
)

target_link_libraries(${PROJECT_NAME}
    ZYNQ
)

add_library(SystemC_model::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_include_directories(${PROJECT_NAME}
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/src
        ${PROJECT_UTILS_PATH}/libsystemctlm-soc
        ${PROJECT_UTILS_PATH}/libsystemctlm-soc/libremote-port
)

set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME ${PROJECT_NAME})

