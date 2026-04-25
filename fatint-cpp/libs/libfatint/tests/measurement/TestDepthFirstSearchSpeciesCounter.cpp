#include "genetics/GeneticsImpl.hpp"
#include "measurement/DepthFirstSearchSpeciesCounter.hpp"
#include "model/types.hpp"

#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.hpp>

TEST_CASE("DepthFirstSearchSpeciesCounter - empty population")
{
    fatint::measurement::DepthFirstSearchSpeciesCounter counter;
    fatint::model::Limits limits;
    limits.m_limit = 1;
    fatint::genetics::SimilarityImpl similarity;
    fatint::model::Population pop;
    size_t count = counter.count_species(limits, similarity, pop);
    CHECK(count == 0);
}

TEST_CASE("DepthFirstSearchSpeciesCounter - single entity")
{
    fatint::measurement::DepthFirstSearchSpeciesCounter counter;
    fatint::model::Limits limits;
    limits.m_limit = 1;
    fatint::genetics::SimilarityImpl similarity;
    fatint::model::Population pop;
    pop.push_back(fatint::model::Entity{
        .age = 0,
        .energy = 0,
        .genotype = {0, 0, 0, 0, 0},
    });
    size_t count = counter.count_species(limits, similarity, pop);
    CHECK(count == 1);
}

TEST_CASE("DepthFirstSearchSpeciesCounter - two similar entities")
{
    fatint::measurement::DepthFirstSearchSpeciesCounter counter;
    fatint::model::Limits limits;
    limits.m_limit = 1;
    fatint::genetics::SimilarityImpl similarity;
    fatint::model::Population pop;
    pop.push_back(fatint::model::Entity{
        .age = 0,
        .energy = 0,
        .genotype = {0, 0, 0, 0, 0},
    });
    pop.push_back(fatint::model::Entity{
        .age = 0,
        .energy = 0,
        .genotype = {1, 0, 0, 0, 0},
    });
    size_t count = counter.count_species(limits, similarity, pop);
    CHECK(count == 1);
}

TEST_CASE("DepthFirstSearchSpeciesCounter - two dissimilar entities")
{
    fatint::measurement::DepthFirstSearchSpeciesCounter counter;
    fatint::model::Limits limits;
    limits.m_limit = 1;
    fatint::genetics::SimilarityImpl similarity;
    fatint::model::Population pop;
    pop.push_back(fatint::model::Entity{
        .age = 0,
        .energy = 0,
        .genotype = {0, 0, 0, 0, 0},
    });
    pop.push_back(fatint::model::Entity{
        .age = 0,
        .energy = 0,
        .genotype = {1, 1, 1, 1, 1},
    });
    size_t count = counter.count_species(limits, similarity, pop);
    CHECK(count == 2);
}

TEST_CASE("DepthFirstSearchSpeciesCounter - two pairs of similar entities")
{
    fatint::measurement::DepthFirstSearchSpeciesCounter counter;
    fatint::model::Limits limits;
    limits.m_limit = 1;
    fatint::genetics::SimilarityImpl similarity;
    fatint::model::Population pop;
    pop.push_back(fatint::model::Entity{
        .age = 0,
        .energy = 0,
        .genotype = {0, 0, 0, 0, 0},
    });
    pop.push_back(fatint::model::Entity{
        .age = 0,
        .energy = 0,
        .genotype = {1, 0, 0, 0, 0},
    });
    pop.push_back(fatint::model::Entity{
        .age = 0,
        .energy = 0,
        .genotype = {1, 1, 1, 1, 0},
    });
    pop.push_back(fatint::model::Entity{
        .age = 0,
        .energy = 0,
        .genotype = {1, 1, 1, 1, 1},
    });
    size_t count = counter.count_species(limits, similarity, pop);
    CHECK(count == 2);
}
