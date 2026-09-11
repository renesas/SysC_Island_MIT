#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "vcml" for configuration "Release"
set_property(TARGET vcml APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(vcml PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libvcml.so.2025.04.29"
  IMPORTED_SONAME_RELEASE "libvcml.so.2025"
  )

list(APPEND _IMPORT_CHECK_TARGETS vcml )
list(APPEND _IMPORT_CHECK_FILES_FOR_vcml "${_IMPORT_PREFIX}/lib/libvcml.so.2025.04.29" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
