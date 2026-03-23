cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
project(fatint)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_EXPORT_COMPILE_COMMANDS on)

add_subdirectory(libs/libfatint)

add_executable(fatint "src/main.cpp")
target_include_directories(fatint PUBLIC "external")
target_link_libraries(fatint PRIVATE libfatint)

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options(fatint PRIVATE -fsanitize=address -fno-omit-frame-pointer)
    target_link_options(fatint PRIVATE -fsanitize=address -fno-omit-frame-pointer)
endif()
