cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
project(libfatint)

option(ENABLE_TESTING "Enable testing" ON)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_EXPORT_COMPILE_COMMANDS on)

add_library(libfatint
    src/stub.cpp
)
target_include_directories(libfatint PUBLIC "include")

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options(libfatint PRIVATE -fsanitize=address -fno-omit-frame-pointer)
    target_link_options(libfatint PRIVATE -fsanitize=address -fno-omit-frame-pointer)
endif()

if (ENABLE_TESTING)
    enable_testing()
    add_subdirectory(tests)
endif()
