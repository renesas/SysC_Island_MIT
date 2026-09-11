cmake_minimum_required(VERSION 3.14)
project(package_utils VERSION 1.0)

set(lua_SOURCE_DIR ${PROJECT_SOURCE_DIR}/lua)
# for systemc language
set(ENABLE_SUSPEND_ALL FALSE)
set(ENABLE_PHASE_CALLBACKS FALSE)
# for systemc cci
set(SystemCLanguage_FOUND TRUE)
set(BUILD_SHARED_LIBS ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
# turn off options
set(RAPIDJSON_BUILD_TESTS OFF CACHE BOOL "")
set(RAPIDJSON_BUILD_DOC OFF CACHE BOOL "")
set(RAPIDJSON_BUILD_EXAMPLES OFF CACHE BOOL "")
set(SYSTEMCCCI_BUILD_TESTS OFF CACHE BOOL "")
set(VCML_BUILD_UTILS OFF CACHE BOOL "")
set(VCML_USE_USB OFF CACHE BOOL "")
set(MWR_USE_LIBELF OFF CACHE BOOL "")


set(VCML_USE_VNC OFF CACHE BOOL "")
# workaround for cci, import target rapidjson
add_subdirectory(rapidjson)
add_library(rapidjson INTERFACE IMPORTED)
target_include_directories(rapidjson INTERFACE
  $<BUILD_INTERFACE:${PROJECT_UTILS_PATH}/Packages/rapidjson/include>
)

add_subdirectory(systemclanguage)
target_include_directories(systemc PUBLIC
 $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/sysc/kernel>
)
set(ENV{CMAKE_PREFIX_PATH} ${PROJECT_UTILS_PATH}/build/Packages/rapidjson)
add_subdirectory(systemccci)

add_subdirectory(libgsutils)

add_subdirectory(libgssync)
 add_subdirectory(base-components)

add_subdirectory(mwr)
add_subdirectory(vcml)
add_subdirectory(vcml-cci)

#########################################
# install systemc cci
#########################################
get_target_property(CCI_SOURCE_DIR cci SOURCE_DIR)
# add more install interface for cci
target_include_directories(cci PUBLIC
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/src>
)

install (
  DIRECTORY ${CCI_SOURCE_DIR}
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
  COMPONENT dev
  FILES_MATCHING PATTERN "cci_configuration"
)

#########################################
# install lua
#########################################
target_include_directories(lua PUBLIC
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/lua/43eeec4c592cc3dddd625e92d4e9176effe470d6>
)

install(
  DIRECTORY ${lua_SOURCE_DIR}
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
  FILES_MATCHING PATTERN "*.h"
)

#########################################
# install mwr
#########################################
set(PROJECT_NAME mwr)
set(TARGET_NAME mwr)
get_target_property(MWR_SOURCE_DIR mwr SOURCE_DIR)
get_target_property(MWR_BINARY_DIR mwr BINARY_DIR)
set(inc ${MWR_SOURCE_DIR}/include)
set(gen ${MWR_BINARY_DIR}/gen)

install(TARGETS mwr DESTINATION lib)
install(DIRECTORY ${inc}/ DESTINATION include)
install(DIRECTORY ${gen}/ DESTINATION include)

set_target_properties(mwr PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ""
)

target_include_directories(mwr PUBLIC
    $<BUILD_INTERFACE:${MWR_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${MWR_BINARY_DIR}/gen>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

install(
  TARGETS ${TARGET_NAME}
  EXPORT ${TARGET_NAME}Targets
  #LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/${TARGET_NAME} COMPONENT Runtime
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}/${TARGET_NAME} COMPONENT Development
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}/${TARGET_NAME} COMPONENT Runtime
  BUNDLE DESTINATION ${CMAKE_INSTALL_BINDIR}/${TARGET_NAME} COMPONENT Runtime
  PUBLIC_HEADER DESTINATION ${INCLUDE_DESTINATION} COMPONENT Development
)

configure_package_config_file(
  ${PROJECT_UTILS_PATH}/Packages/packageproject.cmake/Config.cmake.in
  "${MWR_BINARY_DIR}/${TARGET_NAME}Config.cmake"
  INSTALL_DESTINATION lib/cmake/${TARGET_NAME}
)

install(
  EXPORT ${TARGET_NAME}Targets
  DESTINATION lib/cmake/${TARGET_NAME}
  # NAMESPACE ${TARGET_NAMESPACE}
)

install(
  FILES
    # "${PROJECT_BINARY_DIR}/${TARGET_NAME}ConfigVersion.cmake"
    "${MWR_BINARY_DIR}/${TARGET_NAME}Config.cmake"
  DESTINATION
    lib/cmake/${TARGET_NAME}
)

install(
  TARGETS ${TARGET_NAME}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
          COMPONENT "${TARGET_NAME}_Runtime"
          NAMELINK_COMPONENT "${TARGET_NAME}_Development"
)

#########################################
# install vcml
#########################################
set(PROJECT_NAME vcml)
set(TARGET_NAME vcml)
set(PROJECT_DEPENDENCIES SystemCLanguage;mwr)
get_target_property(VCML_SOURCE_DIR vcml SOURCE_DIR)
get_target_property(VCML_BINARY_DIR vcml BINARY_DIR)

set_target_properties(vcml PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ""
)

target_include_directories(vcml PUBLIC
    $<BUILD_INTERFACE:${VCML_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${VCML_BINARY_DIR}/gen>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

install(
  TARGETS ${TARGET_NAME}
  EXPORT ${TARGET_NAME}Targets
  #LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/${TARGET_NAME} COMPONENT Runtime
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}/${TARGET_NAME} COMPONENT Development
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}/${TARGET_NAME} COMPONENT Runtime
  BUNDLE DESTINATION ${CMAKE_INSTALL_BINDIR}/${TARGET_NAME} COMPONENT Runtime
  PUBLIC_HEADER DESTINATION ${INCLUDE_DESTINATION} COMPONENT Development
)

configure_package_config_file(
  ${PROJECT_UTILS_PATH}/Packages/packageproject.cmake/Config.cmake.in
  "${VCML_BINARY_DIR}/${TARGET_NAME}Config.cmake"
  INSTALL_DESTINATION lib/cmake/${TARGET_NAME}
)

install(
  EXPORT ${TARGET_NAME}Targets
  DESTINATION lib/cmake/${TARGET_NAME}
  NAMESPACE ${TARGET_NAMESPACE}
)

install(
  FILES
    # "${PROJECT_BINARY_DIR}/${TARGET_NAME}ConfigVersion.cmake"
    "${VCML_BINARY_DIR}/${TARGET_NAME}Config.cmake"
  DESTINATION
    lib/cmake/${TARGET_NAME}
)

install(
  TARGETS ${TARGET_NAME}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
          COMPONENT "${TARGET_NAME}_Runtime"
          NAMELINK_COMPONENT "${TARGET_NAME}_Development"
)

#########################################
# install vcml-cci
#########################################
set(PROJECT_NAME vcml-cci)
set(TARGET_NAME vcml-cci)
set(PROJECT_DEPENDENCIES SystemCCCI;SystemCLanguage;vcml)
get_target_property(VCML_CCI_SOURCE_DIR vcml-cci SOURCE_DIR)
get_target_property(VCML_CCI_BINARY_DIR vcml-cci BINARY_DIR)

set_target_properties(vcml-cci PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ""
    INTERFACE_SYSTEM_INCLUDE_DIRECTORIES ""
)

target_include_directories(vcml-cci PUBLIC
    $<BUILD_INTERFACE:${VCML_CCI_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${VCML_CCI_BINARY_DIR}/gen>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

install(
  TARGETS ${TARGET_NAME}
  EXPORT ${TARGET_NAME}Targets
  #LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/${TARGET_NAME} COMPONENT Runtime
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}/${TARGET_NAME} COMPONENT Development
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}/${TARGET_NAME} COMPONENT Runtime
  BUNDLE DESTINATION ${CMAKE_INSTALL_BINDIR}/${TARGET_NAME} COMPONENT Runtime
  PUBLIC_HEADER DESTINATION ${INCLUDE_DESTINATION} COMPONENT Development
)

configure_package_config_file(
  ${PROJECT_UTILS_PATH}/Packages/packageproject.cmake/Config.cmake.in
  "${VCML_CCI_BINARY_DIR}/${TARGET_NAME}Config.cmake"
  INSTALL_DESTINATION lib/cmake/${TARGET_NAME}
)

install(
  EXPORT ${TARGET_NAME}Targets
  DESTINATION lib/cmake/${TARGET_NAME}
  NAMESPACE ${TARGET_NAMESPACE}
)

install(
  FILES
    # "${PROJECT_BINARY_DIR}/${TARGET_NAME}ConfigVersion.cmake"
    "${VCML_CCI_BINARY_DIR}/${TARGET_NAME}Config.cmake"
  DESTINATION
    lib/cmake/${TARGET_NAME}
)

install(
  TARGETS ${TARGET_NAME}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
          COMPONENT "${TARGET_NAME}_Runtime"
          NAMELINK_COMPONENT "${TARGET_NAME}_Development"
)