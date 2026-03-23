#include "genetics/GeneticReproduction.hpp"
#include "genetics/GeneticsImpl.hpp"
#include "measurement/DisjointSetsSpeciesCounter.hpp"
#include "simulation/Simulator.hpp"
#include "simulation/types.hpp"

#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.hpp>

TEST_CASE("Simulator - entities eventually die of old age")
{
  fatint::math::Random random(0);

  fatint::simulation::RunParameters params;
  params.steps = 50;
  params.reproduction_probabilities.p_encounter = 0;

  fatint::genetics::SimilarityImpl similarity(params.limits);
  fatint::genetics::SelectionImpl selection;
  fatint::genetics::MutationImpl mutation;
  fatint::genetics::CrossoverImpl crossover;
  fatint::genetics::GeneticReproduction reproduction(mutation, crossover);
  fatint::genetics::ValidatorImpl validator;
  fatint::genetics::RandomAlleleAdder allele_adder;
  fatint::measurement::DisjointSetsSpeciesCounter species_counter;

  fatint::simulation::Simulator simulator(similarity,
                                          selection,
                                          reproduction,
                                          validator,
                                          allele_adder,
                                          species_counter);

  fatint::simulation::RunStates output = simulator.run(random, params);
  CHECK(output[0].entity_count > 0);
  CHECK(output[1].entity_count > 0);
  CHECK(output[49].entity_count == 0);
}

TEST_CASE("Simulator - entities reproduce")
{
  fatint::math::Random random(0);

  fatint::simulation::RunParameters params;
  params.steps = 50;
  params.allele_parameters.starting_allele_count = 1;
  params.limits.v_min = 0;
  params.limits.v_max = 100;
  params.limits.m_limit = 100;

  fatint::genetics::SimilarityImpl similarity(params.limits);
  fatint::genetics::SelectionImpl selection;
  fatint::genetics::MutationImpl mutation;
  fatint::genetics::CrossoverImpl crossover;
  fatint::genetics::GeneticReproduction reproduction(mutation, crossover);
  fatint::genetics::ValidatorImpl validator;
  fatint::genetics::RandomAlleleAdder allele_adder;
  fatint::measurement::DisjointSetsSpeciesCounter species_counter;

  fatint::simulation::Simulator simulator(similarity,
                                          selection,
                                          reproduction,
                                          validator,
                                          allele_adder,
                                          species_counter);

  fatint::simulation::RunStates output = simulator.run(random, params);

  CHECK(output[0].entity_count > 0);
  CHECK(output[1].entity_count > 0);
  CHECK(output[49].entity_count > 0);
}

TEST_CASE("Simulator - simulation is deterministic")
{
  fatint::math::Random random(0);

  fatint::simulation::RunParameters params;
  params.steps = 50;
  params.allele_parameters.starting_allele_count = 1;
  params.limits.v_min = 0;
  params.limits.v_max = 100;
  params.limits.m_limit = 100;

  fatint::genetics::SimilarityImpl similarity(params.limits);
  fatint::genetics::SelectionImpl selection;
  fatint::genetics::MutationImpl mutation;
  fatint::genetics::CrossoverImpl crossover;
  fatint::genetics::GeneticReproduction reproduction(mutation, crossover);
  fatint::genetics::ValidatorImpl validator;
  fatint::genetics::RandomAlleleAdder allele_adder;
  fatint::measurement::DisjointSetsSpeciesCounter species_counter;

  fatint::simulation::Simulator simulator(similarity,
                                          selection,
                                          reproduction,
                                          validator,
                                          allele_adder,
                                          species_counter);

  fatint::simulation::RunStates output1 = simulator.run(random, params);
  random.seed(0);
  fatint::simulation::RunStates output2 = simulator.run(random, params);

  for (size_t i = 0; i < params.steps; i++) {
    CHECK(output1[i].entity_count == output2[i].entity_count);
    CHECK(output1[i].allele_count == output2[i].allele_count);
    CHECK(output1[i].species_count == output2[i].species_count);
  }
}

TEST_CASE("Simulator - allele count increases")
{
  fatint::math::Random random(0);

  fatint::simulation::RunParameters params;
  params.steps = 50;
  params.allele_parameters.starting_allele_count = 1;
  params.limits.v_min = 0;
  params.limits.v_max = 100;
  params.limits.m_limit = 100;
  params.reproduction_probabilities.p_change = 0.2;

  fatint::genetics::SimilarityImpl similarity(params.limits);
  fatint::genetics::SelectionImpl selection;
  fatint::genetics::MutationImpl mutation;
  fatint::genetics::CrossoverImpl crossover;
  fatint::genetics::GeneticReproduction reproduction(mutation, crossover);
  fatint::genetics::ValidatorImpl validator;
  fatint::genetics::RandomAlleleAdder allele_adder;
  fatint::measurement::DisjointSetsSpeciesCounter species_counter;

  fatint::simulation::Simulator simulator(similarity,
                                          selection,
                                          reproduction,
                                          validator,
                                          allele_adder,
                                          species_counter);

  fatint::simulation::RunStates output = simulator.run(random, params);

  CHECK(output[49].allele_count > 1);
}
