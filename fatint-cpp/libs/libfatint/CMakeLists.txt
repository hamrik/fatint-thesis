cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
project(libfatint)

option(ENABLE_TESTING "Enable testing" ON)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_EXPORT_COMPILE_COMMANDS on)

add_library(libfatint
    src/model/types.cpp
    src/model/utils.cpp
    src/genetics/GeneticReproduction.cpp
    src/genetics/GeneticsImpl.cpp
    src/math/Random.cpp
    src/math/Statistics.cpp
    src/simulation/Environment.cpp
    src/simulation/Experiment.cpp
    src/simulation/Simulator.cpp
    src/simulation/types.cpp
    src/simulation/utils.cpp
    src/measurement/DisjointSetsSpeciesCounter.cpp
    src/io/CSVWriter.cpp
    src/io/SVGWriter.cpp
)
target_include_directories(libfatint PUBLIC
    include
    external
)

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options(libfatint PRIVATE -fsanitize=address -fno-omit-frame-pointer)
    target_link_options(libfatint PRIVATE -fsanitize=address -fno-omit-frame-pointer)
endif()

if (ENABLE_TESTING)
    add_subdirectory(tests)
endif()
