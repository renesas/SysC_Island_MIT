#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "vcml-cci" for configuration "Release"
set_property(TARGET vcml-cci APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(vcml-cci PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libvcml-cci.so.2024.05.27"
  IMPORTED_SONAME_RELEASE "libvcml-cci.so.2024"
  )

list(APPEND _IMPORT_CHECK_TARGETS vcml-cci )
list(APPEND _IMPORT_CHECK_FILES_FOR_vcml-cci "${_IMPORT_PREFIX}/lib/libvcml-cci.so.2024.05.27" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
