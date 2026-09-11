#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "GreenSocs::lua" for configuration "Release"
set_property(TARGET GreenSocs::lua APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(GreenSocs::lua PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/liblua.so"
  IMPORTED_SONAME_RELEASE "liblua.so"
  )

list(APPEND _IMPORT_CHECK_TARGETS GreenSocs::lua )
list(APPEND _IMPORT_CHECK_FILES_FOR_GreenSocs::lua "${_IMPORT_PREFIX}/lib/liblua.so" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
