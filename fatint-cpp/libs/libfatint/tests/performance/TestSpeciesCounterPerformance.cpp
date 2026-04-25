#include "genetics/GeneticsImpl.hpp"
#include "measurement/DepthFirstSearchSpeciesCounter.hpp"
#include "measurement/DisjointSetsSpeciesCounter.hpp"

#include <chrono>
#include <iostream>

#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.hpp>

const auto STARTING_SIZE = 16;
const auto SIZES = 8;
const auto RUNS = 3;

const auto NS_IN_MS = 1e6;

TEST_CASE("SpeciesCounterPerformance - DisjointSets one species")
{
  fatint::measurement::DisjointSetsSpeciesCounter counter;
  fatint::model::Limits limits;
  limits.m_limit = 1;
  fatint::genetics::SimilarityImpl similarity;
  fatint::model::Population pop;

  for (size_t sz = STARTING_SIZE, i = 0; i < SIZES; sz *= 2, i++) {
    pop.clear();
    for (size_t i = 0; i < sz; i++) {
      pop.push_back({ .age = 0, .energy = 0, .genotype = { 0, 0, 0, 0, 0 } });
    }

    double total = 0.0;
    for (int r = 0; r < RUNS; r++) {
      auto before = std::chrono::high_resolution_clock::now();
      size_t count = counter.count_species(limits, similarity, pop);
      auto after = std::chrono::high_resolution_clock::now();
      CHECK(1 == count);

      auto dur =
        std::chrono::duration_cast<std::chrono::nanoseconds>(after - before);
      total += static_cast<double>(dur.count()) / NS_IN_MS;
    }
    std::cout << sz << "," << (total / RUNS) << "\n";
  }
}

TEST_CASE("SpeciesCounterPerformance - DisjointSets many species")
{
  fatint::measurement::DisjointSetsSpeciesCounter counter;
  fatint::model::Limits limits;
  limits.m_limit = 1;
  fatint::genetics::SimilarityImpl similarity;
  fatint::model::Population pop;

  for (size_t sz = STARTING_SIZE, i = 0; i < SIZES; sz *= 2, i++) {
    pop.clear();
    for (size_t i = 0; i < sz; i++) {
      int g = static_cast<int>(i);
      pop.push_back({ .age = 0, .energy = 0, .genotype = { g, g, g, g, g } });
    }

    double total = 0.0;
    for (int r = 0; r < RUNS; r++) {
      auto before = std::chrono::high_resolution_clock::now();
      size_t count = counter.count_species(limits, similarity, pop);
      auto after = std::chrono::high_resolution_clock::now();
      CHECK(sz == count);

      auto dur = std::chrono::duration_cast<std::chrono::nanoseconds>(after - before);
      total += static_cast<double>(dur.count()) / NS_IN_MS;
    }
    std::cout << sz << "," << (total / RUNS) << "\n";
  }
}

TEST_CASE("SpeciesCounterPerformance - DepthFirstSearch one species")
{
  fatint::measurement::DepthFirstSearchSpeciesCounter counter;
  fatint::model::Limits limits;
  limits.m_limit = 1;
  fatint::genetics::SimilarityImpl similarity;
  fatint::model::Population pop;

  for (size_t sz = STARTING_SIZE, i = 0; i < SIZES; sz *= 2, i++) {
    pop.clear();
    for (size_t i = 0; i < sz; i++) {
      pop.push_back({ .age = 0, .energy = 0, .genotype = { 0, 0, 0, 0, 0 } });
    }

    double total = 0.0;
    for (int r = 0; r < RUNS; r++) {
      auto before = std::chrono::high_resolution_clock::now();
      size_t count = counter.count_species(limits, similarity, pop);
      auto after = std::chrono::high_resolution_clock::now();
      CHECK(1 == count);

      auto dur =
        std::chrono::duration_cast<std::chrono::nanoseconds>(after - before);
      total += static_cast<double>(dur.count()) / NS_IN_MS;
    }
    std::cout << sz << "," << (total / RUNS) << "\n";
  }
}

TEST_CASE("SpeciesCounterPerformance - DepthFirstSearch many species") {
  fatint::measurement::DepthFirstSearchSpeciesCounter counter;
  fatint::model::Limits limits;
  limits.m_limit = 1;
  fatint::genetics::SimilarityImpl similarity;
  fatint::model::Population pop;

  for (size_t sz = STARTING_SIZE, i = 0; i < SIZES; sz *= 2, i++) {
    pop.clear();
    for (size_t i = 0; i < sz; i++) {
      int g = static_cast<int>(i);
      pop.push_back({ .age = 0, .energy = 0, .genotype = { g, g, g, g, g } });
    }

    double total = 0.0;
    for (int r = 0; r < RUNS; r++) {
      auto before = std::chrono::high_resolution_clock::now();
      size_t count = counter.count_species(limits, similarity, pop);
      auto after = std::chrono::high_resolution_clock::now();
      CHECK(sz == count);

      auto dur =
        std::chrono::duration_cast<std::chrono::nanoseconds>(after - before);
      total += static_cast<double>(dur.count()) / NS_IN_MS;
    }
    std::cout << sz << "," << (total / RUNS) << "\n";
  }
}
