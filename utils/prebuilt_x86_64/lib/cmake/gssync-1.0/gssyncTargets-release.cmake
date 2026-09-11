#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "GreenSocs::gssync" for configuration "Release"
set_property(TARGET GreenSocs::gssync APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(GreenSocs::gssync PROPERTIES
  IMPORTED_LINK_DEPENDENT_LIBRARIES_RELEASE "SystemC::systemc;SystemC::cci"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/gssync-1.0/libgssync.so"
  IMPORTED_SONAME_RELEASE "libgssync.so"
  )

list(APPEND _IMPORT_CHECK_TARGETS GreenSocs::gssync )
list(APPEND _IMPORT_CHECK_FILES_FOR_GreenSocs::gssync "${_IMPORT_PREFIX}/lib/gssync-1.0/libgssync.so" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
