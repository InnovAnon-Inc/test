add_executable(app main.c)
target_compile_features(app PRIVATE cxx_std_17)

#target_link_libraries(app PRIVATE modern_library fmt::fmt)
target_link_libraries(app PRIVATE modern_library)

