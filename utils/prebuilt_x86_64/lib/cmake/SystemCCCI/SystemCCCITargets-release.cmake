#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "SystemC::cci" for configuration "Release"
set_property(TARGET SystemC::cci APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(SystemC::cci PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libcci.so.1.0.1"
  IMPORTED_SONAME_RELEASE "libcci.so.1.0"
  )

list(APPEND _IMPORT_CHECK_TARGETS SystemC::cci )
list(APPEND _IMPORT_CHECK_FILES_FOR_SystemC::cci "${_IMPORT_PREFIX}/lib/libcci.so.1.0.1" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
