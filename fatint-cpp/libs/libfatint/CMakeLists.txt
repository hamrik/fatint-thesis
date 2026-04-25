cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
project(libfatint)

option(ENABLE_TESTING "Enable testing" ON)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_library(libfatint
    src/model/types.cpp
    src/model/utils.cpp
    src/genetics/GeneticReproduction.cpp
    src/genetics/GeneticsImpl.cpp
    src/math/Random.cpp
    src/math/Statistics.cpp
    src/simulation/Environment.cpp
    src/simulation/Simulator.cpp
    src/simulation/types.cpp
    src/simulation/utils.cpp
    src/measurement/DepthFirstSearchSpeciesCounter.cpp
    src/measurement/DisjointSetsSpeciesCounter.cpp
    src/io/CSVWriter.cpp
    src/io/SVGWriter.cpp
)
target_include_directories(libfatint
    PUBLIC include
    SYSTEM PRIVATE external
)

find_package(TBB)
if(TBB_FOUND)
    target_link_libraries(libfatint PUBLIC TBB::tbb)
endif()

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options(libfatint PRIVATE -fsanitize=address -fno-omit-frame-pointer)
    target_link_options(libfatint PRIVATE -fsanitize=address -fno-omit-frame-pointer)
endif()

target_compile_options(libfatint PRIVATE -Wconversion -Wall -Werror)

if (ENABLE_TESTING)
    add_subdirectory(tests)
endif()
