# Testing library
#FetchContent_Declare(
#  catch
#  GIT_REPOSITORY https://github.com/catchorg/Catch2.git
#  GIT_TAG v2.13.6)
#FetchContent_MakeAvailable(catch)
# Adds Catch2::Catch2
FetchContent_Declare(
  check
  #GIT_REPOSITORY https://github.com/mikkoi/check.git
  GIT_REPOSITORY https://github.com/libcheck/check.git
  #GIT_TAG        origin/fix-for-cmake-fetchcontent
  GIT_TAG 0.15.2
)
FetchContent_MakeAvailable(check)

#find_package(PkgConfig)
#pkg_check_modules(CHECK check IMPORTED_TARGET GLOBAL)

# Tests need to be added as executables first
add_executable(check_foo check_foo.c)

# I'm using C++17 in the test
target_compile_features(check_foo PRIVATE cxx_std_17)

# Should be linked to the main library, as well as the Catch2 testing library
#target_link_libraries(check_foo PRIVATE modern_library Catch2::Catch2)
#target_link_libraries(check_foo PRIVATE modern_library Check::Check)
target_link_libraries(check_foo PRIVATE modern_library Check::check)
#target_link_libraries(check_foo PRIVATE modern_library PkgConfig::Check)

# If you register a test, then ctest and make test will run it.
# You can also run examples and check the output, as well.
add_test(NAME check_footest COMMAND check_foo) # Command can be a target

