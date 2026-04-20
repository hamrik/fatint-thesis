#include "genetics/GeneticsImpl.hpp"
#include "math/Random.hpp"
#include "model/formulas.hpp"
#include "model/types.hpp"
#include <climits>

#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.hpp>

TEST_CASE("SimilarityImpl - similar entities are compatible")
{
  fatint::model::Limits limits;
  limits.m_limit = 1;

  fatint::genetics::SimilarityImpl similarity;

  fatint::model::Genotype a = { 0, 0, 0, 0, 0 };
  fatint::model::Genotype b = { 0, 0, 0, 0, 1 };

  CHECK(similarity.compatible(limits, a, b) == true);
}

TEST_CASE("SimilarityImpl - dissimilar entities are not compatible")
{
  fatint::model::Limits limits;
  limits.m_limit = 1;

  fatint::genetics::SimilarityImpl similarity;

  fatint::model::Genotype a = { 0, 0, 0, 0, 0 };
  fatint::model::Genotype b = { 0, 0, 0, 1, 1 };

  CHECK(similarity.compatible(limits, a, b) == false);
}

TEST_CASE("MutationImpl - does not mutate when p_mutation is 0")
{
  fatint::math::Random random;
  random.seed(0);

  fatint::genetics::MutationImpl mutation;
  fatint::model::Genotype genotype;
  for (size_t i = 0; i < 100; i++) {
    genotype.push_back(0);
  }

  mutation.mutate(random, 0, INT_MAX, genotype);

  int zeros = 0;
  for (auto allele : genotype) {
    if (allele == 0) {
      zeros++;
    }
  }

  CHECK(zeros == genotype.size());
}

TEST_CASE("MutationImpl - mutates all alleles when p_mutation is 1")
{
  fatint::math::Random random;
  random.seed(0);

  fatint::genetics::MutationImpl mutation;
  fatint::model::Genotype genotype;
  for (size_t i = 0; i < 100; i++) {
    genotype.push_back(0);
  }

  mutation.mutate(random, 1, INT_MAX, genotype);

  int zeros = 0;
  for (auto allele : genotype) {
    if (allele == 0) {
      zeros++;
    }
  }

  CHECK(zeros == 0);
}

TEST_CASE("CrossoverImpl - selects A for all alleles when p_crossover is 0")
{
  fatint::math::Random random;
  random.seed(0);

  fatint::genetics::CrossoverImpl crossover;
  fatint::model::Genotype a = { 0, 0, 0, 0, 0 };
  fatint::model::Genotype b = { 1, 1, 1, 1, 1 };

  crossover.crossover(random, 0, a, b, a);

  int zeros = 0;
  for (auto allele : a) {
    if (allele == 0) {
      zeros++;
    }
  }

  CHECK(zeros == 5);
}

TEST_CASE("CrossoverImpl - selects B for all alleles when p_crossover is 1")
{
  fatint::math::Random random;
  random.seed(0);

  fatint::genetics::CrossoverImpl crossover;
  fatint::model::Genotype a = { 0, 0, 0, 0, 0 };
  fatint::model::Genotype b = { 1, 1, 1, 1, 1 };

  crossover.crossover(random, 1, a, b, a);

  int zeros = 0;
  for (auto allele : a) {
    if (allele == 0) {
      zeros++;
    }
  }

  CHECK(zeros == 0);
}

TEST_CASE("ValidatorImpl - correctly identifies outliers")
{
  fatint::genetics::ValidatorImpl validator;

  fatint::model::Limits limits;
  limits.v_min = 0;
  limits.v_max = 1;

  fatint::model::Genotype good = { 0, 1, 1, 0, 0 };
  fatint::model::Genotype bad = { 0, -1, 2, 0, 1 };

  CHECK(validator.validate(limits, good) == true);
  CHECK(validator.validate(limits, bad) == false);
}

TEST_CASE("RandomAlleleAdder - correctly adds alleles")
{
  fatint::math::Random random;
  random.seed(0);

  fatint::genetics::RandomAlleleAdder random_allele_adder;

  fatint::model::Limits limits;
  limits.v_min = -5;
  limits.v_max = 5;
  fatint::model::AlleleParameters parameters;

  fatint::model::Genotype genotype = { 0, 0, 0, 0, 0 };

  random_allele_adder.add_allele(random, limits, parameters, genotype);

  CHECK(genotype.size() == 6);
  CHECK(genotype.back() >= limits.v_min);
  CHECK(genotype.back() <= limits.v_max);
}

TEST_CASE(
  "VStretchAlleleAdderImpl - correctly adds alleles using v-stretch formula")
{
  fatint::math::Random random;
  random.seed(0);

  fatint::genetics::VStretchAlleleAdder v_stretch_allele_adder;

  fatint::model::Limits limits;
  fatint::model::AlleleParameters parameters;
  parameters.v_stretch = 1;

  fatint::model::Genotype genotype = { 0, 0, 0, 0, 5 };
  int expected = fatint::model::stretch_allele(
    5, limits.v_min, limits.v_max, parameters.v_stretch);

  v_stretch_allele_adder.add_allele(random, limits, parameters, genotype);

  CHECK(genotype.size() == 6);
  CHECK(genotype.back() == expected);
}
