cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
project(testlibfatint)

set(TESTS
  model/TestFormulas.cpp
  model/TestUtils.cpp
  genetics/TestGeneticsImpl.cpp
  simulation/TestSimulationUtils.cpp
  simulation/TestSimulator.cpp
  math/TestRandom.cpp
  math/TestStatistics.cpp
  measurement/TestDepthFirstSearchSpeciesCounter.cpp
  measurement/TestDisjointSetsSpeciesCounter.cpp
  measurement/TestReservoirSampling.cpp
  performance/TestSimulatorPerformance.cpp
  performance/TestSpeciesCounterPerformance.cpp
)

enable_testing()

foreach(TEST_FILE ${TESTS})
  get_filename_component(TEST ${TEST_FILE} NAME_WLE)

  add_executable(${TEST} ${TEST_FILE})
  target_include_directories(${TEST} SYSTEM PRIVATE ../external)
  target_link_libraries(${TEST} libfatint)

  target_compile_options(${TEST} PRIVATE -fsanitize=address -fno-omit-frame-pointer -Wconversion -Wall -Werror -Wno-error=maybe-uninitialized)
  target_link_options(${TEST} PRIVATE -fsanitize=address -fno-omit-frame-pointer)

  add_test(NAME ${TEST} COMMAND ${TEST})
endforeach()
