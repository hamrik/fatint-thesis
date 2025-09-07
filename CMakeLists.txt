cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

project(fatint)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_EXPORT_COMPILE_COMMANDS on)

find_package(TBB)

add_executable(fatint
    "src/main.cpp"
    "src/population.cpp"
    "src/disjointsets.cpp")
target_include_directories(fatint PUBLIC "include")

if (${TBB_FOUND})
    message(STATUS "Using TBB for parallel runs")
    target_link_libraries(fatint PRIVATE TBB::tbb)
else()
    message(WARNING "TBB not found, falling back to single-threaded concurrency. Multi-run simulations will be slow.")
endif()

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options(fatint PRIVATE -fsanitize=address -fno-omit-frame-pointer)
    target_link_options(fatint PRIVATE -fsanitize=address -fno-omit-frame-pointer)
endif()
