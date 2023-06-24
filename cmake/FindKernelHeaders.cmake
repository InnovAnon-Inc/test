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
    include/linux/user.h
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

