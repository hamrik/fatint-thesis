cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

project(fatint)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_EXPORT_COMPILE_COMMANDS on)

add_executable(fatint
    "src/main.cpp"
    "src/population.cpp"
    "src/disjointsets.cpp")
target_include_directories(fatint PUBLIC "include")
 
target_link_libraries(fatint tbb)
#target_compile_options(fatint PRIVATE -fsanitize=address -fno-omit-frame-pointer)
#target_link_options(fatint PRIVATE -fsanitize=address -fno-omit-frame-pointer)
