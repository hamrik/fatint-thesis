#include "genetics/GeneticsImpl.hpp"
#include "measurement/DepthFirstSearchSpeciesCounter.hpp"
#include "measurement/DisjointSetsSpeciesCounter.hpp"

#include <chrono>
#include <iostream>

#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.hpp>

TEST_CASE("SpeciesCounterPerformance - DisjointSets one species")
{
  fatint::measurement::DisjointSetsSpeciesCounter counter;
  fatint::model::Limits limits;
  limits.m_limit = 1;
  fatint::genetics::SimilarityImpl similarity;
  fatint::model::Population pop;

  std::cout << "counter,size,nanoseconds,species" << std::endl;
  const auto SIZES = 16;
  for (size_t sz = 1, i = 0; i < SIZES; sz *= 2, i++) {
    pop.clear();
    for (size_t i = 0; i < sz; i++) {
      pop.push_back({ .age = 0, .energy = 0, .genotype = { 0, 0, 0, 0, 0 } });
    }

    auto before = std::chrono::high_resolution_clock::now();
    size_t count = counter.count_species(limits, similarity, pop);
    auto after = std::chrono::high_resolution_clock::now();

    auto dur =
      std::chrono::duration_cast<std::chrono::nanoseconds>(after - before);

    std::cout << "DisjointSetsSingle," << sz << "," << dur.count() << "," << count << "\n";
  }
}

TEST_CASE("SpeciesCounterPerformance - DisjointSets many species")
{
  fatint::measurement::DisjointSetsSpeciesCounter counter;
  fatint::model::Limits limits;
  limits.m_limit = 1;
  fatint::genetics::SimilarityImpl similarity;
  fatint::model::Population pop;

  std::cout << "counter,size,nanoseconds,species" << std::endl;
  const auto SIZES = 16;
  for (size_t sz = 1, i = 0; i < SIZES; sz *= 2, i++) {
    pop.clear();
    for (size_t i = 0; i < sz; i++) {
      pop.push_back({ .age = 0,
                      .energy = 0,
                      .genotype = { static_cast<int>(i),
                                    static_cast<int>(i),
                                    static_cast<int>(i),
                                    static_cast<int>(i),
                                    static_cast<int>(i) } });
    }

    auto before = std::chrono::high_resolution_clock::now();
    size_t count = counter.count_species(limits, similarity, pop);
    auto after = std::chrono::high_resolution_clock::now();

    auto dur =
      std::chrono::duration_cast<std::chrono::nanoseconds>(after - before);

    std::cout << "DisjointSetsMany," << sz << "," << dur.count() << "," << count << "\n";
  }
}

TEST_CASE("SpeciesCounterPerformance - DepthFirstSearch one species")
{
  fatint::measurement::DepthFirstSearchSpeciesCounter counter;
  fatint::model::Limits limits;
  limits.m_limit = 1;
  fatint::genetics::SimilarityImpl similarity;
  fatint::model::Population pop;

  std::cout << "counter,size,nanoseconds,species" << std::endl;
  const auto SIZES = 16;
  for (size_t sz = 1, i = 0; i < SIZES; sz *= 2, i++) {
    pop.clear();
    for (size_t i = 0; i < sz; i++) {
      pop.push_back({ .age = 0, .energy = 0, .genotype = { 0, 0, 0, 0, 0 } });
    }

    auto before = std::chrono::high_resolution_clock::now();
    size_t count = counter.count_species(limits, similarity, pop);
    auto after = std::chrono::high_resolution_clock::now();

    auto dur =
      std::chrono::duration_cast<std::chrono::nanoseconds>(after - before);

    std::cout << "DepthFirstSearchSingle," << sz << "," << dur.count() << "," << count << "\n";
  }
}

TEST_CASE("SpeciesCounterPerformance - DepthFirstSearch many species") {
  fatint::measurement::DepthFirstSearchSpeciesCounter counter;
  fatint::model::Limits limits;
  limits.m_limit = 1;
  fatint::genetics::SimilarityImpl similarity;
  fatint::model::Population pop;

  std::cout << "counter,size,nanoseconds,species" << std::endl;
  const auto SIZES = 16;
  for (size_t sz = 1, i = 0; i < SIZES; sz *= 2, i++) {
    pop.clear();
    for (size_t i = 0; i < sz; i++) {
      pop.push_back({ .age = 0,
                      .energy = 0,
                      .genotype = { static_cast<int>(i),
                                    static_cast<int>(i),
                                    static_cast<int>(i),
                                    static_cast<int>(i),
                                    static_cast<int>(i) } });
    }

    auto before = std::chrono::high_resolution_clock::now();
    size_t count = counter.count_species(limits, similarity, pop);
    auto after = std::chrono::high_resolution_clock::now();

    auto dur =
      std::chrono::duration_cast<std::chrono::nanoseconds>(after - before);

    std::cout << "DepthFirstSearchMany," << sz << "," << dur.count() << "," << count << "\n";
  }
}
