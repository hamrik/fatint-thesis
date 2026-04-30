#include "genetics/GeneticsImpl.hpp"
#include "math/Random.hpp"
#include "model/formulas.hpp"
#include "model/types.hpp"

#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.hpp>

TEST_CASE("EuclideanDistanceSimilarity - similar entities are compatible")
{
    fatint::genetics::EuclideanDistanceSimilarity similarity({ .m_limit = 1});

    fatint::model::Entity a
    {
        .age = 0, .energy = 0, .genotype = {0, 0, 0, 0, 0}
    };
    fatint::model::Entity b{.age = 0, .energy = 0, .genotype = {0, 0, 0, 0, 1}};

    CHECK(similarity.compatible(a, b) == true);
}

TEST_CASE("EuclideanDistanceSimilarity - dissimilar entities are not compatible")
{
    fatint::genetics::EuclideanDistanceSimilarity similarity({ .m_limit = 1});

    fatint::model::Entity a
    {
        .age = 0, .energy = 0, .genotype = {0, 0, 0, 0, 0}
    };
    fatint::model::Entity b{.age = 0, .energy = 0, .genotype = {0, 0, 0, 1, 1}};

    CHECK(similarity.compatible(a, b) == false);
}

TEST_CASE("BoundedMutation - does not mutate when p_mutation is 0")
{
    fatint::model::Genotype genotype;
    for (size_t i = 0; i < 100; i++)
    {
        genotype.push_back(0);
    }

    fatint::genetics::BoundedMutation mutation(0, 10);
    fatint::math::Random random(0);
    mutation.mutate(random, genotype);

    int zeros = 0;
    for (auto gene : genotype)
    {
        if (gene == 0)
        {
            zeros++;
        }
    }

    CHECK(zeros == genotype.size());
}

TEST_CASE("BoundedMutation - mutates all genes when p_mutation is 1")
{
    fatint::model::Genotype genotype;
    for (size_t i = 0; i < 100; i++)
    {
        genotype.push_back(0);
    }

    fatint::genetics::BoundedMutation mutation(1, 10000);
    fatint::math::Random random(0);
    mutation.mutate(random, genotype);

    int zeros = 0;
    for (auto gene : genotype)
    {
        if (gene == 0)
        {
            zeros++;
        }
    }

    CHECK(zeros == 0);
}

TEST_CASE("Crossover - selects A for all genes when p_crossover is 0")
{
    fatint::genetics::Crossover crossover(0);
    fatint::model::Genotype a = {0, 0, 0, 0, 0};
    fatint::model::Genotype b = {1, 1, 1, 1, 1};
    fatint::model::Genotype c = {2, 2, 2, 2, 2};

    fatint::math::Random random(0);
    crossover.combine(random, a, b, c);

    int zeros = 0;
    int ones = 0;
    for (auto gene : c)
    {
        if (gene == 0)
        {
            zeros++;
        }
        else if (gene == 1)
        {
            ones++;
        }
    }

    CHECK(zeros == 5);
    CHECK(ones == 0);
}

TEST_CASE("Crossover - selects B for all genes when p_crossover is 1")
{
    fatint::genetics::Crossover crossover(1);
    fatint::model::Genotype a = {0, 0, 0, 0, 0};
    fatint::model::Genotype b = {1, 1, 1, 1, 1};
    fatint::model::Genotype c = {2, 2, 2, 2, 2};

    fatint::math::Random random(0);
    crossover.combine(random, a, b, c);

    int zeros = 0;
    int ones = 0;
    for (auto gene : c)
    {
        if (gene == 0)
        {
            zeros++;
        }
        else if (gene == 1)
        {
            ones++;
        }
    }

    CHECK(zeros == 0);
    CHECK(ones == 5);
}

TEST_CASE("RandomGeneAdder - correctly adds genes")
{
    fatint::math::Random random(0);

    fatint::genetics::RandomGeneAdder random_gene_adder(-5, 5);

    fatint::model::Genotype genotype = {0, 0, 0, 0, 0};

    for(int i = 0; i < 100; i++)
    {
        random_gene_adder.add_gene(random, genotype);
        CHECK(genotype.size() == 6 + i);
        CHECK(genotype.back() >= -5);
        CHECK(genotype.back() <= 5);
    }
}

TEST_CASE("VStretchGeneAdder - correctly adds genes using v-stretch "
          "formula")
{
    fatint::math::Random random(0);

    fatint::model::Genotype genotype = {0, 0, 0, 0, 5};

    fatint::genetics::VStretchGeneAdder v_stretch_gene_adder(0, 100, 1);
    v_stretch_gene_adder.add_gene(random, genotype);

    int expected = fatint::model::stretch_gene(5, 0, 100, 1);
    CHECK(genotype.size() == 6);
    CHECK(genotype.back() == expected);
}
