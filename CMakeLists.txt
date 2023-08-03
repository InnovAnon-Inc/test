# Works with 3.14 and tested through 3.26
cmake_minimum_required(VERSION 3.14...3.26)
#cmake_minimum_required(VERSION 3.0 FATAL_ERROR)

# Project name and a few useful settings. Other commands can pick up the results
project(
  ModernCMakeExample
  #VERSION 0.1
  DESCRIPTION "An example project with CMake"
  LANGUAGES C ASM)
set(CMAKE_C_STANDARD 11) 
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CPACK_PACKAGE_NAME "MyApp")
#set(CPACK_PACKAGE_VERSION_MAJOR 1)
#set(CPACK_PACKAGE_VERSION_MINOR 0)
#set(CPACK_PACKAGE_VERSION_PATCH 0)



set(CMAKE_EXPORT_COMPILE_COMMANDS true)

# Change this to your module name 
set(module_name "hello")

# Random definitions that I'm not sure are needed :^)
add_definitions(-D__KERNEL__ -DMODULE)

# Disallow in source builds
get_filename_component(srcdir "${CMAKE_SOURCE_DIR}" REALPATH)
get_filename_component(bindir "${CMAKE_BINARY_DIR}" REALPATH)

if(srcdir STREQUAL bindir)
  message(FATAL_ERROR "In source builds are not allowed. 
  Create a build directory and run cmake from there.")
endif()




# Find kernel headers
#list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
#find_package(KernelHeaders REQUIRED)

# BIG THANK YOU TO THE ORIGINAL AUTHOR
# https://gitlab.com/christophacham/cmake-kernel-module

# Find the kernel release
execute_process(
  COMMAND uname -r
  OUTPUT_VARIABLE KERNEL_RELEASE
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

if ("${KERNEL_MODULES_DIR}" STREQUAL "")
  set (
    KERNEL_MODULES_DIR "/lib/modules/${KERNEL_RELEASE}/build"
    CACHE STRING
    "Path to the kernel build directory"
  )
endif()

find_file(
  kernel_makefile
  NAMES Makefile
  PATHS ${KERNEL_MODULES_DIR}
  NO_DEFAULT_PATH
)
if (NOT kernel_makefile)
  message(FATAL_ERROR "Kernel makefile not found in ${KERNEL_MODULES_DIR}")
endif()

if ("${KERNEL_HEADERS_DIR}" STREQUAL "")
  # Find the kernel headers directory
  # If you are using another kernel branch like 'linux-zen'
  # you might need to change the directory
  # in which the header file is searched
  # Or you can set the kernel_headers_dir directly
  find_path(
    KERNEL_HEADERS_DIR
    #include/linux/user.h
    NAMES include
    PATHS /usr/src/linux-headers-${KERNEL_RELEASE}
  )
endif()

if (NOT KERNEL_HEADERS_DIR)
  message(FATAL_ERROR "Kernel headers not found. Modifications to CMakeLists.txt needed.")
endif()

execute_process(
  COMMAND uname -m
  OUTPUT_VARIABLE KERNEL_ARCH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

message(STATUS "Kernel release:      ${KERNEL_RELEASE}")
message(STATUS "Kernel architecture: ${KERNEL_ARCH}")
message(STATUS "Kernel modules:      ${KERNEL_MODULES_DIR}")
message(STATUS "Kernel headers:      ${KERNEL_HEADERS_DIR}")

if (KERNEL_HEADERS_DIR)
  set(
    KERNELHEADERS_INCLUDE_DIRS
    ${KERNEL_HEADERS_DIR}/include
    ${KERNEL_HEADERS_DIR}/arch/${KERNEL_ARCH}/include
    CACHE PATH "Kernel headers include dirs"
  )
  set(KERNELHEADERS_FOUND 1 CACHE STRING "Set to 1 if kernel headers were found")
else (KERNEL_HEADERS_DIR)
    set(KERNELHEADERS_FOUND 0 CACHE STRING "Set to 1 if kernel headers were found")
endif (KERNEL_HEADERS_DIR)

mark_as_advanced(KERNELHEADERS_FOUND)



























# Add kernel include directories to compilation process
# This gives us juicy autocomplete
include_directories(${KERNEL_HEADERS_DIR}/include)

# TODO
#file(GLOB HEADER_LIST CONFIGURE_DEPENDS "${ModernCMakeExample_SOURCE_DIR}/include/modern/*.h")

# For some reason on my machine building the kernel module does 
# not emit the 'compile_commands.json' file required for autocomplete
# This is why there is a dummy static library compiled.
# If you want you can use this to compile an actual static library
# that you can use for unit tests or whatever.
add_library(modern_library STATIC "src/foo.c" ${HEADER_LIST})

target_include_directories(modern_library PRIVATE ${KERNELHEADERS_INCLUDE_DIRS})
# TODO
#target_include_directories(modern_library PUBLIC ../include)
#source_group(
#  TREE "${PROJECT_SOURCE_DIR}/include"
#  PREFIX "Header Files"
#  FILES ${HEADER_LIST})

# If you used the dummy library for something not 'dummy' you can
# uncomment the following line to add the library sources to the
# kernel module.
# get_target_property(module_sources dummy-lib SOURCES)
get_target_property(module_sources modern_library SOURCES)
list(APPEND module_sources "apps/${module_name}.c")

# Generate the list of source files that are going to be 
# converted to object files in the Kbuild file
string(REPLACE ";" " " module_sources_str "${module_sources}")
# Replace variables in Kbuild.in and output that to Kbuild
configure_file(Kbuild.in Kbuild @ONLY)

# Copy the source files to the directory cmake was configured in.
# This as to not complicate the makefile.
# TODO: Maybe find a better solution that would also allow for in-tree builds
foreach (src ${module_sources})
  configure_file(${src} ${src} COPYONLY)
endforeach()

# Add command to build the .ko file
set(module_cmd ${CMAKE_MAKE_PROGRAM} -C ${KERNEL_MODULES_DIR} M=${CMAKE_CURRENT_BINARY_DIR})
add_custom_command(OUTPUT "${module_name}.ko"
  COMMAND ${module_cmd} modules
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  DEPENDS ${module_sources} ${CMAKE_CURRENT_BINARY_DIR}/Kbuild
  VERBATIM)

# Add name agnostic build commands
add_custom_target(module DEPENDS "${module_name}.ko")
add_custom_target(module-clean COMMAND ${module_cmd} clean)





























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

#include(InstallRequiredSystemLibraries)
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")

set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)
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

