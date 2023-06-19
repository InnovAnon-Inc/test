# Works with 3.14 and tested through 3.26
cmake_minimum_required(VERSION 3.14...3.26)

# Project name and a few useful settings. Other commands can pick up the results
project(
  ModernCMakeExample
  #VERSION 0.1
  DESCRIPTION "An example project with CMake"
  LANGUAGES C CXX)
set(CPACK_PACKAGE_NAME "MyApp")
#set(CPACK_PACKAGE_VERSION_MAJOR 1)
#set(CPACK_PACKAGE_VERSION_MINOR 0)
#set(CPACK_PACKAGE_VERSION_PATCH 0)

ADD_CUSTOM_TARGET(
  auto_increment_version
  ${CMAKE_COMMAND}
  -D VERSION_FILE=${CMAKE_SOURCE_DIR}/version.h
  -P ${CMAKE_SOURCE_DIR}/AutoVersion.cmake
)

# Only do these if this is the main project, and not if it is included through add_subdirectory
if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)

  # Optionally set things like CMAKE_CXX_STANDARD, CMAKE_POSITION_INDEPENDENT_CODE here

  # Let's ensure -std=c++xx instead of -std=g++xx
  set(CMAKE_CXX_EXTENSIONS OFF)

  # Let's nicely support folders in IDEs
  set_property(GLOBAL PROPERTY USE_FOLDERS ON)

  # Testing only available if this is the main app
  # Note this needs to be done in the main CMakeLists
  # since it calls enable_testing, which must be in the
  # main CMakeLists.
  include(CTest)

  # Docs only available if this is the main app
  find_package(Doxygen
    REQUIRED dot
    OPTIONAL_COMPONENTS mscgen dia)
  if(Doxygen_FOUND)
    add_subdirectory(docs)
  else()
    message(STATUS "Doxygen not found, not building docs")
  endif()
endif()

# FetchContent added in CMake 3.11, downloads during the configure step
# FetchContent_MakeAvailable was added in CMake 3.14; simpler usage
include(FetchContent)

# Accumulator library
# This is header only, so could be replaced with git submodules or FetchContent
#find_package(Boost REQUIRED)
# Adds Boost::boost

# Formatting library
#FetchContent_Declare(
#  fmtlib
#  GIT_REPOSITORY https://github.com/fmtlib/fmt.git
#  GIT_TAG 5.3.0)
#FetchContent_MakeAvailable(fmtlib)
# Adds fmt::fmt

# The compiled library code is here
add_subdirectory(src)

# The executable code is here
add_subdirectory(apps)

# Testing only available if this is the main app
# Emergency override MODERN_CMAKE_BUILD_TESTING provided as well
if((CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME OR MODERN_CMAKE_BUILD_TESTING)
   AND BUILD_TESTING)
  add_subdirectory(tests)
endif()

#install(TARGETS app RUNTIME DESTINATION bin)

include(InstallRequiredSystemLibraries)
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
#set(CPACK_PACKAGE_VERSION_MAJOR "${Tutorial_VERSION_MAJOR}")
#set(CPACK_PACKAGE_VERSION_MINOR "${Tutorial_VERSION_MINOR}")

#set(CPACK_SOURCE_GENERATOR "TXZ")
#set(CPACK_BINARY_GENERATOR "TXZ")
set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)
#option(CPACK_BINARY_TXZ ON)
#set(CPACK_GENERATOR "7Z;IFW;NSIS;NSIS64;STGZ;TBZ2;TGZ;TXZ;TZ;WIX;ZIP")
#set(CPACK_GENERATOR "7Z;STGZ;TBZ2;TGZ;TXZ;TZ;ZIP;DEB;RPM;TZST;NuGet")
#set(CPACK_GENERATOR "7Z;STGZ;TBZ2;TGZ;TXZ;TZ;ZIP;DEB;TZST;NuGet")
set(CPACK_GENERATOR "7Z;STGZ;TBZ2;TGZ;TXZ;TZ;ZIP;DEB")
set(CPACK_PACKAGE_CONTACT "InnovAnon-Inc@gmx.com")
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Innovations Anonymous")
set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)
set(CPACK_COMPONENTS_GROUPING ONE_PER_GROUP)
set(CPACK_DEB_COMPONENT_INSTALL YES)
#set(CPACK_DEBIAN_PACKAGE_DEPENDS)
set(CPACK_SOURCE_IGNORE_FILES
  \\.git/
  build/
  ".*~$"
)
set(CPACK_VERBATIM_VARIABLES YES)

set(CPACK_PACKAGE_VENDOR "InnovAnon, Inc.")
set(CPACK_PACKAGE_HOMEPAGE_URL "https://InnovAnon-Inc.github.io/test")
#set(CPACK_PACKAGE_DESCRIPTION "")
#set(CPACK_PACKAGE_DESCRIPTION_FILE "")
#set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "")
#set(CPACK_PACKAGE_ICON "")
set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
#set(CPACK_RESOURCE_FILE_WELCOME "${CMAKE_CURRENT_SOURCE_DIR}/WELCOME")
set(CPACK_STRIP_FILES TRUE)

include(CPack)

