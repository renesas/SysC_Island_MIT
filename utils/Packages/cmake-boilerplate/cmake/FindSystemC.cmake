#.rst:
# FindSystemC
# -----------
#
# Try to find SystemC

set(_SYSTEMC_PATHS PATHS
    ${SYSTEMC_PREFIX}
    $ENV{SYSTEMC_PREFIX}
    ${SYSTEMC_HOME}
    $ENV{SYSTEMC_HOME}
)

find_path(SystemC_INCLUDE_DIR systemc NO_DEFAULT_PATH PATHS ${_SYSTEMC_PATHS} PATH_SUFFIXES include src)

if (NOT SystemC_LIBRARIES)
    find_library(SystemC_LIBRARY_DEBUG NAMES systemc ${_SYSTEMC_PATHS} PATH_SUFFIXES lib lib-linux lib-linux64 lib-mingw64 msvc10/SystemC/x64/DebugDLL)
    find_library(SystemC_LIBRARY_RELEASE NAMES systemc ${_SYSTEMC_PATHS} PATH_SUFFIXES lib lib-linux lib-linux64 lib-mingw64 msvc10/SystemC/x64/ReleaseDLL)

    include(SelectLibraryConfigurations)
    SELECT_LIBRARY_CONFIGURATIONS(SystemC)
endif ()

if (SystemC_INCLUDE_DIR AND EXISTS "${SystemC_INCLUDE_DIR}/sysc/kernel/sc_ver.h")
    file(STRINGS "${SystemC_INCLUDE_DIR}/sysc/kernel/sc_ver.h" _sc_ver REGEX "^#define SC_VERSION_.*")
    string(REGEX REPLACE ".*#define SC_VERSION_MAJOR[\t ]+([0-9]+).*" "\\1" SystemC_MAJOR "${_sc_ver}")
    string(REGEX REPLACE ".*#define SC_VERSION_MINOR[\t ]+([0-9]+).*" "\\1" SystemC_MINOR "${_sc_ver}")
    string(REGEX REPLACE ".*#define SC_VERSION_PATCH[\t ]+([0-9]+).*" "\\1" SystemC_PATCH "${_sc_ver}")

    set(SystemC_VERSION "${SystemC_MAJOR}.${SystemC_MINOR}.${SystemC_PATCH}")
endif ()

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(SystemC
    REQUIRED_VARS SystemC_LIBRARIES SystemC_INCLUDE_DIR
    VERSION_VAR SystemC_VERSION)

if (NOT TARGET SystemC::systemc)
    add_library(SystemC::systemc UNKNOWN IMPORTED)
    set_property(TARGET SystemC::systemc APPEND PROPERTY
        IMPORTED_CONFIGURATIONS RELEASE)
    set_target_properties(SystemC::systemc PROPERTIES
        IMPORTED_LOCATION_RELEASE "${SystemC_LIBRARY_RELEASE}"
        INTERFACE_INCLUDE_DIRECTORIES "${SystemC_INCLUDE_DIR}")
    if (SystemC_LIBRARY_DEBUG)
        set_property(TARGET SystemC::systemc APPEND PROPERTY
            IMPORTED_CONFIGURATIONS DEBUG)
        set_target_properties(SystemC::systemc PROPERTIES
            IMPORTED_LOCATION_DEBUG "${SystemC_LIBRARY_DEBUG}")
    endif ()
    set(SystemCLanguage_FOUND TRUE)
endif()

foreach(COMPONENT ${SystemC_FIND_COMPONENTS})
    if (${COMPONENT} STREQUAL "CCI")
        set(_CCI_PATHS PATHS
            ${CCI_HOME}
            $ENV{CCI_HOME}
            )

        find_path(CCI_INCLUDE_DIR cci_configuration ${_CCI_PATHS} PATH_SUFFIXES src include)

        if (NOT CCI_LIBRARIES)
            find_library(CCI_LIBRARY_DEBUG NAMES cciapi ${_CCI_PATHS} PATH_SUFFIXES lib lib-linux lib-linux64 lib-mingw64 msvc10/cci/libs/x64/Debug)
            find_library(CCI_LIBRARY_RELEASE NAMES cciapi ${_CCI_PATHS} PATH_SUFFIXES lib lib-linux lib-linux64 lib-mingw64 msvc10/cci/libs/x64/Release)

            include(SelectLibraryConfigurations)
            SELECT_LIBRARY_CONFIGURATIONS(CCI)
        endif ()

        if (CCI_INCLUDE_DIR AND EXISTS "${CCI_INCLUDE_DIR}/cci_core/cci_version.h")
            file(STRINGS "${CCI_INCLUDE_DIR}/cci_core/cci_version.h" _cci_ver REGEX "^#define CCI_VERSION_.*")
            string(REGEX REPLACE ".*#define CCI_VERSION_MAJOR[\t ]+([0-9]+).*" "\\1" CCI_MAJOR "${_cci_ver}")
            string(REGEX REPLACE ".*#define CCI_VERSION_MINOR[\t ]+([0-9]+).*" "\\1" CCI_MINOR "${_cci_ver}")
            string(REGEX REPLACE ".*#define CCI_VERSION_PATCH[\t ]+([0-9]+).*" "\\1" CCI_PATCH "${_cci_ver}")

            set(CCI_VERSION "${CCI_MAJOR}.${CCI_MINOR}.${CCI_PATCH}")
        else ()
            message( SEND_ERROR "Please set CCI_HOME (currently $ENV{CCI_HOME})" )
        endif ()

        set(FPHSA_NAME_MISMATCHED 1)

        include(FindPackageHandleStandardArgs)
        FIND_PACKAGE_HANDLE_STANDARD_ARGS(CCI
            REQUIRED_VARS CCI_LIBRARIES CCI_INCLUDE_DIR
            VERSION_VAR CCI_VERSION)

        unset(FPHSA_NAME_MISMATCHED)

        if (NOT TARGET SystemC::CCI)
            add_library(SystemC::CCI UNKNOWN IMPORTED)

            set_property(TARGET SystemC::CCI APPEND PROPERTY
                IMPORTED_CONFIGURATIONS RELEASE)
            set_target_properties(SystemC::CCI PROPERTIES
                IMPORTED_LOCATION_RELEASE "${CCI_LIBRARY_RELEASE}"
                INTERFACE_INCLUDE_DIRECTORIES "${CCI_INCLUDE_DIR}")

            if (CCI_LIBRARY_DEBUG)
                set_property(TARGET SystemC::CCI APPEND PROPERTY
                    IMPORTED_CONFIGURATIONS DEBUG)
                set_target_properties(SystemC::CCI PROPERTIES
                    IMPORTED_LOCATION_DEBUG "${CCI_LIBRARY_DEBUG}")
            endif ()
        endif ()
    else ()
        message( FATAL_ERROR "Unknown SystemC component ${COMPONENT}" )
    endif ()
endforeach ()
