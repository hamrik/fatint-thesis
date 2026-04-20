#include "genetics/GeneticsImpl.hpp"
#include "measurement/DisjointSetsSpeciesCounter.hpp"
#include "model/types.hpp"

#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.hpp>

TEST_CASE("DisjointSetsSpeciesCounter - empty population")
{
  fatint::measurement::DisjointSetsSpeciesCounter counter;
  fatint::model::Limits limits;
  limits.m_limit = 1;
  fatint::genetics::SimilarityImpl similarity;
  fatint::model::Population pop;
  size_t count = counter.count_species(limits, similarity, pop);
  CHECK(count == 0);
}

TEST_CASE("DisjointSetsSpeciesCounter - single entity")
{
  fatint::measurement::DisjointSetsSpeciesCounter counter;
  fatint::model::Limits limits;
  limits.m_limit = 1;
  fatint::genetics::SimilarityImpl similarity;
  fatint::model::Population pop;
  pop.push_back(fatint::model::Entity{
    .age = 0,
    .energy = 0,
    .genotype = { 0, 0, 0, 0, 0 },
  });
  size_t count = counter.count_species(limits, similarity, pop);
  CHECK(count == 1);
}

TEST_CASE("DisjointSetsSpeciesCounter - two similar entities")
{
  fatint::measurement::DisjointSetsSpeciesCounter counter;
  fatint::model::Limits limits;
  limits.m_limit = 1;
  fatint::genetics::SimilarityImpl similarity;
  fatint::model::Population pop;
  pop.push_back(fatint::model::Entity{
    .age = 0,
    .energy = 0,
    .genotype = { 0, 0, 0, 0, 0 },
  });
  pop.push_back(fatint::model::Entity{
    .age = 0,
    .energy = 0,
    .genotype = { 1, 0, 0, 0, 0 },
  });
  size_t count = counter.count_species(limits, similarity, pop);
  CHECK(count == 1);
}

TEST_CASE("DisjointSetsSpeciesCounter - two dissimilar entities")
{
  fatint::measurement::DisjointSetsSpeciesCounter counter;
  fatint::model::Limits limits;
  limits.m_limit = 1;
  fatint::genetics::SimilarityImpl similarity;
  fatint::model::Population pop;
  pop.push_back(fatint::model::Entity{
    .age = 0,
    .energy = 0,
    .genotype = { 0, 0, 0, 0, 0 },
  });
  pop.push_back(fatint::model::Entity{
    .age = 0,
    .energy = 0,
    .genotype = { 1, 1, 1, 1, 1 },
  });
  size_t count = counter.count_species(limits, similarity, pop);
  CHECK(count == 2);
}

TEST_CASE("DisjointSetsSpeciesCounter - two pairs of similar entities")
{
  fatint::measurement::DisjointSetsSpeciesCounter counter;
  fatint::model::Limits limits;
  limits.m_limit = 1;
  fatint::genetics::SimilarityImpl similarity;
  fatint::model::Population pop;
  pop.push_back(fatint::model::Entity{
    .age = 0,
    .energy = 0,
    .genotype = { 0, 0, 0, 0, 0 },
  });
  pop.push_back(fatint::model::Entity{
    .age = 0,
    .energy = 0,
    .genotype = { 1, 0, 0, 0, 0 },
  });
  pop.push_back(fatint::model::Entity{
    .age = 0,
    .energy = 0,
    .genotype = { 1, 1, 1, 1, 0 },
  });
  pop.push_back(fatint::model::Entity{
    .age = 0,
    .energy = 0,
    .genotype = { 1, 1, 1, 1, 1 },
  });
  size_t count = counter.count_species(limits, similarity, pop);
  CHECK(count == 2);
}
