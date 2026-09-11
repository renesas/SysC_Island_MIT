cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

# ##############################################################################
# ----- BOILERPLATE should be included on all projects sets up test, and
# sub-project (CPM) support Sets C++ standard to 14.
# ##############################################################################
if(PROJECT_SOURCE_DIR STREQUAL PROJECT_BINARY_DIR)
  message(FATAL_ERROR "Please use a build directory.")
endif()

set(gs-cmake_SOURCE_DIR "${gs-cmake_SOURCE_DIR}" CACHE STRING "the location of the gs-boilerplate source")

# Only include/use/update a pre-existing package cache. Otherwise, a package
# cache can be built by including it on the command line with -DCPM_SOURCE_CACHE
if(EXISTS "${PROJECT_UTILS_PATH}/Packages")
  message(STATUS "Using Packages cache")
  set(ENV{CPM_SOURCE_CACHE} "${PROJECT_UTILS_PATH}/Packages")
  set(PROJECT_PATH ${PROJECT_UTILS_PATH})
endif()

include(FetchContent)
include(CTest)

if(EXISTS "${PROJECT_UTILS_PATH}/Packages/CPM.cmake/cmake/CPM.cmake")
  include(${PROJECT_UTILS_PATH}/Packages/CPM.cmake/cmake/CPM.cmake)
else()
  FetchContent_Declare(
    cpm-cmake
    GIT_REPOSITORY https://github.com/cpm-cmake/CPM.cmake.git
    GIT_TAG v0.31.1)
  FetchContent_MakeAvailable(cpm-cmake)
  include(${cpm-cmake_SOURCE_DIR}/cmake/CPM.cmake)
endif()

macro(gs_addexpackage)
  if (NOT DEFINED GS_ONLY)
    cpmaddpackage(${ARGV})
  endif()
endmacro()

if(EXISTS ${PROJECT_UTILS_PATH}/Packages/packageproject.cmake/CMakeLists.txt)
  include(${PROJECT_UTILS_PATH}/Packages/packageproject.cmake/CMakeLists.txt)
else()
  gs_addexpackage("gh:TheLartians/PackageProject.cmake@1.4.1")
endif()

set(CMAKE_CXX_STANDARD
    14
    CACHE STRING "C++ standard to build all targets.")
set(CMAKE_CXX_STANDARD_REQUIRED
    ON
    CACHE BOOL
          "The with CMAKE_CXX_STANDARD selected C++ standard is a requirement.")
mark_as_advanced(CMAKE_CXX_STANDARD_REQUIRED)

include(GNUInstallDirs)

set(DEFAULT_GREENSOCS_GIT "git@git.greensocs.com:"  CACHE STRING "Default fallback Git URL")
set(DEFAULT_ACCELLERA_GIT "git@git.greensocs.com:accellera/"  CACHE STRING "Default fallback Git URL")
set(ACCELLERA_GIT "" CACHE STRING "Git directory from which to clone accellera repositoies")
set(GREENSOCS_GIT "" CACHE STRING "Git directory from which to clone all gs repositoies")

if ( "${GREENSOCS_GIT}" STREQUAL "")
  set(GREENSOCS_GIT "${DEFAULT_GREENSOCS_GIT}")
  if ( "${GIT_BRANCH}" STREQUAL "")
    execute_process(COMMAND git rev-parse --abbrev-ref HEAD
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                    OUTPUT_VARIABLE GIT_BRANCH)   
    message (STATUS "The GIT URL and branch are by default : ${GREENSOCS_GIT} (Default Branch: ${GIT_BRANCH})")
  else()
    message (STATUS "The GIT URL is by default: ${GREENSOCS_GIT} (Branch: ${GIT_BRANCH})")
  endif()
  execute_process(COMMAND git config --get branch.${GIT_BRANCH}.remote
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                    OUTPUT_VARIABLE GIT_REMOTE)
  execute_process(COMMAND git config --get remote.${GIT_REMOTE}.url
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                    OUTPUT_VARIABLE GIT_URL)

  if ("${GIT_URL}" MATCHES "^(ssh:\/\/[^/]+/).*")
    string (REGEX REPLACE "^(ssh:\/\/[^/]+/).*" "\\1" GREENSOCS_GIT "${GIT_URL}")
  elseif("${GIT_URL}" MATCHES  "^(https:\/\/[^/]+/).*")
    string (REGEX REPLACE "^(https:\/\/[^/]+/).*" "\\1" GREENSOCS_GIT "${GIT_URL}")
  elseif("${GIT_URL}" MATCHES  "^([a-z][-a-z0-9]*\@[^:]*:).*")
    string (REGEX REPLACE "^([a-z][-a-z0-9]*\@[^:]*:).*" "\\1" GREENSOCS_GIT "${GIT_URL}")
  endif()
endif()

if ( "${ACCELLERA_GIT}" STREQUAL "")
  set(ACCELLERA_GIT "${DEFAULT_ACCELLERA_GIT}")
endif()
if ("${CMAKE_INSTALL_PREFIX}" STREQUAL "" OR "${CMAKE_INSTALL_PREFIX}" STREQUAL "/usr/local")
    set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/install)
    message(STATUS "CMAKE PREFIX PATH = ${CMAKE_INSTALL_PREFIX}")
endif()

if(APPLE)
  set(CMAKE_INSTALL_RPATH "\@executable_path/../lib;\@executable_path/../lib/libqemu")
else()
  set(CMAKE_INSTALL_RPATH "\$ORIGIN/../lib;\$ORIGIN/../lib/libqemu")
endif()
set(CMAKE_BUILD_RPATH "${CMAKE_BINARY_DIR}/_deps/libqemu-build/qemu-prefix/lib/")

if (EXISTS ${CMAKE_SOURCE_DIR}/conf.lua)
  install(FILES ${CMAKE_SOURCE_DIR}/conf.lua DESTINATION ${CMAKE_INSTALL_PREFIX})
endif()
if (EXISTS ${CMAKE_SOURCE_DIR}/fw)
  install(DIRECTORY ${CMAKE_SOURCE_DIR}/fw DESTINATION ${CMAKE_INSTALL_PREFIX})
endif()

# Allow using package-lock.cmake files in projects using this boilerplate to pin repos, etc.
# set(PKG_LOCK "package-lock.cmake" CACHE STRING "Package lock which will be used by the user")
# CPMUsePackageLock(${PKG_LOCK})
# ##############################################################################

# ##############################################################################
# ------- Documentation target -- these target is to be used within GreenSocs to
# update documentation. -- it is not expected to be run by customers.
# ##############################################################################
# if(NOT TARGET updatedocs)
#   find_package(Doxygen QUIET)
#   find_package(LATEX QUIET)
#   find_program(NodeJS node QUIET)
#   find_program(NPM npm QUIET)
#   if(DOXYGEN_FOUND
#      AND NPM
#      AND NodeJS
#      AND LATEX_FOUND)
#     # set input and output files
#     set(DOXYGEN_IN ${gs-cmake_SOURCE_DIR}/doxygen.in)
#     set(DOXYGEN_FILE ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile)
#     set(DOXYGEN_OUT ${CMAKE_CURRENT_BINARY_DIR}/doc_doxygen)

#     # request to configure the file
#     configure_file(${DOXYGEN_IN} ${DOXYGEN_FILE} @ONLY)
#     message(STATUS "Doxygen Configuration initialised")

#     add_custom_command(
#       OUTPUT ${DOXYGEN_OUT}
#       MAIN_DEPENDENCY ${CMAKE_SOURCE_DIR}/README.md
#       COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_FILE}
#       WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
#       COMMENT "Generating API documentation with Doxygen"
#       VERBATIM)
#     add_custom_command(
#       OUTPUT ${DOXYGEN_OUT}/latex/refman.pdf
#       MAIN_DEPENDENCY ${DOXYGEN_OUT}
#       COMMAND make
#       WORKING_DIRECTORY ${DOXYGEN_OUT}/latex
#       COMMENT "Generating pdf with latex"
#       VERBATIM)
#     add_custom_command(
#       OUTPUT ${DOXYGEN_OUT}/${PROJECT_NAME}_README.md
#       MAIN_DEPENDENCY ${DOXYGEN_OUT}
#       COMMAND ${NPM} i doxygen2md
#       COMMAND ${NodeJS} node_modules/doxygen2md ${DOXYGEN_OUT}/xml >
#               ${DOXYGEN_OUT}/${PROJECT_NAME}_README.md
#       WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})

#     add_custom_target(
#       updatedocs
#       COMMENT "Documents being installed in ${CMAKE_SOURCE_DIR}/docs"
#       DEPENDS ${DOXYGEN_OUT}/latex/refman.pdf
#       COMMAND mkdir -p ${CMAKE_SOURCE_DIR}/docs
#       COMMAND cp ${DOXYGEN_OUT}/latex/refman.pdf
#               ${CMAKE_SOURCE_DIR}/docs/${PROJECT_NAME}.pdf
#       COMMAND ${gs-cmake_SOURCE_DIR}/doc_merge.pl ${CMAKE_SOURCE_DIR})

#   else()
#     add_custom_target(
#       updatedocs ALL
#       COMMENT
#         "Document generation dependencies not found. Requires Doxygen Latex"
#       COMMAND true)
#   endif()
# endif()
# ##############################################################################

set(CMAKE_FIND_USE_PACKAGE_REGISTRY FALSE)

# ##############################################################################
# ----- SystemC and CCI Dependencies
# ##############################################################################
macro(gs_systemc)

  # if(DEFINED ENV{SYSTEMC_HOME} OR DEFINED SYSTEMC_HOME)
  #   include(${gs-cmake_SOURCE_DIR}/cmake/FindSystemC.cmake)
  # else()
  #   gs_addexpackage(
  #     NAME
  #     SystemCLanguage
  #     GIT_REPOSITORY
  #     git@github.com:machineware-gmbh/gs-systemc.git
  #     GIT_TAG
  #     async_suspendable
  #     GIT_SHALLOW
  #     True
  #     OPTIONS
  #     "ENABLE_SUSPEND_ALL"
  #     "ENABLE_PHASE_CALLBACKS")
  #     # Prevent CCI attempting to re-find SystemC
  #   if(SystemCLanguage_ADDED)
  #       set(SystemCLanguage_FOUND TRUE)
  #   endif()

  #   message(STATUS "Using SystemC ${SystemCLanguage_VERSION} (${SystemCLanguage_SOURCE_DIR})")
  # endif()

  # gs_addexpackage(
  #   NAME
  #   RapidJSON
  #   GIT_REPOSITORY
  #   https://github.com/Tencent/rapidjson
  #   GIT_TAG
  #   e0f68a435610e70ab5af44fc6a90523d69b210b3
  #   GIT_SHALLOW
  #   FALSE
  #   OPTIONS
  #   "RAPIDJSON_BUILD_TESTS OFF"
  #   "RAPIDJSON_BUILD_DOC OFF"
  #   "RAPIDJSON_BUILD_EXAMPLES OFF")

  # set(RapidJSON_DIR "${RapidJSON_BINARY_DIR}")

  # gs_addexpackage(
  #   NAME
  #   SystemCCCI
  #   GIT_REPOSITORY
  #   git@github.com:machineware-gmbh/gs-cci.git
  #   GIT_TAG
  #   accellera-automake-flow
  #   GIT_SHALLOW
  #   True
  #   OPTIONS
  #   "SYSTEMCCCI_BUILD_TESTS OFF")

  # message(STATUS "Using SystemCCI ${SystemCCCI_VERSION} (${SystemCCCI_SOURCE_DIR})")

  # set(SYSTEMC_PROJECT TRUE)

  if (NOT DEFINED GS_ONLY)
    list(APPEND TARGET_LIBS "rapidjson;SystemC::systemc;SystemC::cci")
    set(TARGET_LIBS "${TARGET_LIBS}" CACHE INTERNAL "target_libs")
  endif()

  # message("\nIn ${PROJECT_NAME}, not really add SystemC, just workaround!\n")
endmacro()

# ----- configure include paths and EXPORT PROJECT
macro(gs_export)
  if (NOT DEFINED GS_ONLY)
    string(TOLOWER ${PROJECT_NAME}/version.h VERSION_HEADER_LOCATION)
    add_library("lib${PROJECT_NAME}" ALIAS ${PROJECT_NAME})
    add_library("GreenSocs::lib${PROJECT_NAME}" ALIAS ${PROJECT_NAME})

    if(${PROJECT_NAME} STREQUAL "gsutils")
      packageproject(
        NAME
        "${PROJECT_NAME}"
        VERSION
        ${PROJECT_VERSION}
        NAMESPACE
        GreenSocs
        BINARY_DIR
        ${PROJECT_BINARY_DIR}
        INCLUDE_DIR
        ${PROJECT_SOURCE_DIR}/include
        INCLUDE_DESTINATION
        ${CMAKE_INSTALL_INCLUDEDIR}
        VERSION_HEADER
        "${VERSION_HEADER_LOCATION}"
        DEPENDENCIES
        RapidJSON
        SystemCLanguage
        SystemCCCI
        COMPATIBILITY
        SameMajorVersion)
    elseif(${PROJECT_NAME} STREQUAL "gssync")
        packageproject(
          NAME
          "${PROJECT_NAME}"
          VERSION
          ${PROJECT_VERSION}
          NAMESPACE
          GreenSocs
          BINARY_DIR
          ${PROJECT_BINARY_DIR}
          INCLUDE_DIR
          ${PROJECT_SOURCE_DIR}/include
          INCLUDE_DESTINATION
          ${CMAKE_INSTALL_INCLUDEDIR}
          VERSION_HEADER
          "${VERSION_HEADER_LOCATION}"
          DEPENDENCIES
          gsutils
          COMPATIBILITY
          SameMajorVersion)
    elseif(${PROJECT_NAME} STREQUAL "base-components")
          packageproject(
            NAME
            "${PROJECT_NAME}"
            VERSION
            ${PROJECT_VERSION}
            NAMESPACE
            GreenSocs
            BINARY_DIR
            ${PROJECT_BINARY_DIR}
            INCLUDE_DIR
            ${PROJECT_SOURCE_DIR}/include
            INCLUDE_DESTINATION
            ${CMAKE_INSTALL_INCLUDEDIR}
            VERSION_HEADER
            "${VERSION_HEADER_LOCATION}"
            DEPENDENCIES
            gsutils
          COMPATIBILITY
            SameMajorVersion)
    endif()

    install(
      TARGETS ${PROJECT_NAME}
      LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
              COMPONENT "${PROJECT_NAME}_Runtime"
              NAMELINK_COMPONENT "${PROJECT_NAME}_Development"
    )
    list(APPEND TARGET_LIBS "GreenSocs::${PROJECT_NAME}")
    set(TARGET_LIBS "${TARGET_LIBS}" CACHE INTERNAL "target_libs")
  endif()
endmacro()

# by default switch on verbosity

macro (gs_addpackage name)
  string (REGEX REPLACE ".*/([^/]+)" "\\1" GSPACKAGENAME "${name}")
  # CPMAddPackage(
  #   NAME "${GSPACKAGENAME}"
  #   GIT_REPOSITORY "${GREENSOCS_GIT}${name}.git"
  #   GIT_TAG "${GIT_BRANCH}" 
  #   GIT_SHALLOW on
  #   ${ARGN}
  # )
  # message("\nIn ${PROJECT_NAME}, not really add ${GSPACKAGENAME}, just workaround!\n")
endmacro()

configure_file(${gs-cmake_SOURCE_DIR}/CTestCustom.cmake ${CMAKE_BINARY_DIR})
# macro(gs_enable_testing)
#   if(BUILD_TESTING AND ("${PROJECT_NAME}" STREQUAL "${CMAKE_PROJECT_NAME}"))
#     if (googletest_ADDED)
#       target_link_libraries(${PROJECT_NAME} INTERFACE gtest gmock)
#     endif()
#     enable_testing()
#     add_subdirectory(tests)
#   endif()
# endmacro()
