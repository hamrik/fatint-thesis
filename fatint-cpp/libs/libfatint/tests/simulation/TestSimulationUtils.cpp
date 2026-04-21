#include "simulation/utils.hpp"

#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.hpp>

TEST_CASE("RunParameters operator+= accumulates all fields")
{
  fatint::simulation::RunParameters a;
  a.steps = 100;
  a.seed = 42;
  a.limits.v_min = 0;
  a.limits.v_max = 10;
  a.limits.m_limit = 5.0;
  a.reproduction_probabilities.p_encounter = 0.1;
  a.reproduction_probabilities.p_change = 0.2;
  a.reproduction_parameters.starting_population = 100;
  a.reproduction_parameters.m_const = 2.0;
  a.reproduction_parameters.m_slope = 0.5;
  a.genetic_probabilities.p_crossing = 0.3;
  a.genetic_probabilities.p_mutation = 0.4;
  a.allele_parameters.starting_allele_count = 10;
  a.allele_parameters.v_mutation = 1.0;
  a.allele_parameters.v_stretch = 1.5;
  a.energy_parameters.e_increase = 10.0;
  a.energy_parameters.e_consumption = 1.0;
  a.energy_parameters.e_intake = 5.0;
  a.energy_parameters.e_discount = 0.9;

  fatint::simulation::RunParameters b;
  b.steps = 50;
  b.seed = 10;
  b.limits.v_min = 1;
  b.limits.v_max = 5;
  b.limits.m_limit = 2.0;
  b.reproduction_probabilities.p_encounter = 0.05;
  b.reproduction_probabilities.p_change = 0.1;
  b.reproduction_parameters.starting_population = 50;
  b.reproduction_parameters.m_const = 1.0;
  b.reproduction_parameters.m_slope = 0.25;
  b.genetic_probabilities.p_crossing = 0.2;
  b.genetic_probabilities.p_mutation = 0.1;
  b.allele_parameters.starting_allele_count = 5;
  b.allele_parameters.v_mutation = 2;
  b.allele_parameters.v_stretch = 0.25;
  b.energy_parameters.e_increase = 5.0;
  b.energy_parameters.e_consumption = 0.5;
  b.energy_parameters.e_intake = 2.0;
  b.energy_parameters.e_discount = 0.05;

  a += b;

  // Note: operator+= does NOT modify steps and seed
  CHECK(a.steps == 100); // unchanged
  CHECK(a.seed == 42);   // unchanged
  CHECK(a.limits.v_min == 1);
  CHECK(a.limits.v_max == 15);
  CHECK(a.limits.m_limit == doctest::Approx(7.0));
  CHECK(a.reproduction_probabilities.p_encounter == doctest::Approx(0.15));
  CHECK(a.reproduction_probabilities.p_change == doctest::Approx(0.3));
  CHECK(a.reproduction_parameters.starting_population == 150);
  CHECK(a.reproduction_parameters.m_const == doctest::Approx(3.0));
  CHECK(a.reproduction_parameters.m_slope == doctest::Approx(0.75));
  CHECK(a.genetic_probabilities.p_crossing == doctest::Approx(0.5));
  CHECK(a.genetic_probabilities.p_mutation == doctest::Approx(0.5));
  CHECK(a.allele_parameters.starting_allele_count == 15);
  CHECK(a.allele_parameters.v_mutation == 3);
  CHECK(a.allele_parameters.v_stretch == doctest::Approx(1.75));
  CHECK(a.energy_parameters.e_increase == doctest::Approx(15.0));
  CHECK(a.energy_parameters.e_consumption == doctest::Approx(1.5));
  CHECK(a.energy_parameters.e_intake == doctest::Approx(7.0));
  CHECK(a.energy_parameters.e_discount == doctest::Approx(0.95));
}

TEST_CASE("expandExperimentParameters creates correct number of runs")
{
  fatint::simulation::ExperimentParameters params;
  params.runs = 5;
  params.run_parameters.steps = 100;
  params.run_parameters.seed = 42;
  params.run_parameters.limits.v_min = 0;
  params.run_parameters.limits.v_max = 10;
  params.run_parameters.limits.m_limit = 5.0;
  params.run_parameters.reproduction_probabilities.p_encounter = 0.1;
  params.run_parameters.reproduction_probabilities.p_change = 0.2;
  params.run_parameters.reproduction_parameters.starting_population = 100;
  params.run_parameters.reproduction_parameters.m_const = 2.0;
  params.run_parameters.reproduction_parameters.m_slope = 0.5;
  params.run_parameters.genetic_probabilities.p_crossing = 0.3;
  params.run_parameters.genetic_probabilities.p_mutation = 0.4;
  params.run_parameters.allele_parameters.starting_allele_count = 10;
  params.run_parameters.allele_parameters.v_mutation = 1.0;
  params.run_parameters.allele_parameters.v_stretch = 1.5;
  params.run_parameters.energy_parameters.e_increase = 10.0;
  params.run_parameters.energy_parameters.e_consumption = 1.0;
  params.run_parameters.energy_parameters.e_intake = 5.0;
  params.run_parameters.energy_parameters.e_discount = 0.9;

  auto run_params = fatint::simulation::expandExperimentParameters(params);

  CHECK(run_params.size() == 5);

  // Check that seeds are incremented
  for (size_t i = 0; i < run_params.size(); i++) {
    CHECK(run_params[i].seed == 42 + i);
    CHECK(run_params[i].steps == 100);
  }
}

TEST_CASE(
  "expandExperimentSweepParameters creates correct number of experiments")
{
  fatint::simulation::ExperimentSweepParameters sweep_params;
  sweep_params.experiments = 3;
  sweep_params.starting_parameters.runs = 2;
  sweep_params.starting_parameters.run_parameters.steps = 100;
  sweep_params.starting_parameters.run_parameters.seed = 10;
  sweep_params.starting_parameters.run_parameters.limits.v_min = 0;
  sweep_params.starting_parameters.run_parameters.limits.v_max = 10;
  sweep_params.starting_parameters.run_parameters.limits.m_limit = 5.0;
  sweep_params.starting_parameters.run_parameters.reproduction_probabilities
    .p_encounter = 0.1;
  sweep_params.starting_parameters.run_parameters.reproduction_probabilities
    .p_change = 0.2;
  sweep_params.starting_parameters.run_parameters.reproduction_parameters
    .starting_population = 100;
  sweep_params.starting_parameters.run_parameters.reproduction_parameters
    .m_const = 2.0;
  sweep_params.starting_parameters.run_parameters.reproduction_parameters
    .m_slope = 0.5;
  sweep_params.starting_parameters.run_parameters.genetic_probabilities
    .p_crossing = 0.3;
  sweep_params.starting_parameters.run_parameters.genetic_probabilities
    .p_mutation = 0.4;
  sweep_params.starting_parameters.run_parameters.allele_parameters
    .starting_allele_count = 10;
  sweep_params.starting_parameters.run_parameters.allele_parameters.v_mutation =
    1.0;
  sweep_params.starting_parameters.run_parameters.allele_parameters.v_stretch =
    1.5;
  sweep_params.starting_parameters.run_parameters.energy_parameters.e_increase =
    10.0;
  sweep_params.starting_parameters.run_parameters.energy_parameters
    .e_consumption = 1.0;
  sweep_params.starting_parameters.run_parameters.energy_parameters.e_intake =
    5.0;
  sweep_params.starting_parameters.run_parameters.energy_parameters.e_discount =
    0.9;

  // Delta to increment each experiment
  sweep_params.delta.steps = 50;
  sweep_params.delta.seed = 0; // Don't increment seed in delta
  sweep_params.delta.limits.v_min = 0;
  sweep_params.delta.limits.v_max = 0;
  sweep_params.delta.limits.m_limit = 0.0;
  sweep_params.delta.reproduction_probabilities.p_encounter = 0.0;
  sweep_params.delta.reproduction_probabilities.p_change = 0.0;
  sweep_params.delta.reproduction_parameters.starting_population = 0;
  sweep_params.delta.reproduction_parameters.m_const = 0.0;
  sweep_params.delta.reproduction_parameters.m_slope = 0.0;
  sweep_params.delta.genetic_probabilities.p_crossing = 0.0;
  sweep_params.delta.genetic_probabilities.p_mutation = 0.0;
  sweep_params.delta.allele_parameters.starting_allele_count = 0;
  sweep_params.delta.allele_parameters.v_mutation = 0.0;
  sweep_params.delta.allele_parameters.v_stretch = 0.0;
  sweep_params.delta.energy_parameters.e_increase = 0.0;
  sweep_params.delta.energy_parameters.e_consumption = 0.0;
  sweep_params.delta.energy_parameters.e_intake = 0.0;
  sweep_params.delta.energy_parameters.e_discount = 0.0;

  auto experiment_params =
    fatint::simulation::expandExperimentSweepParameters(sweep_params);

  CHECK(experiment_params.size() == 3);

  // operator+= does NOT modify steps/seed, so delta.steps has no effect
  // All experiments will have the same steps value
  CHECK(experiment_params[0].run_parameters.steps == 100);
  CHECK(experiment_params[1].run_parameters.steps == 100);
  CHECK(experiment_params[2].run_parameters.steps == 100);
}

TEST_CASE("fullyExpandExperimentSweepParameters creates all run parameters")
{
  fatint::simulation::ExperimentSweepParameters sweep_params;
  sweep_params.experiments = 2;
  sweep_params.starting_parameters.runs = 3;
  sweep_params.starting_parameters.run_parameters.steps = 100;
  sweep_params.starting_parameters.run_parameters.seed = 1;
  sweep_params.starting_parameters.run_parameters.limits.v_min = 0;
  sweep_params.starting_parameters.run_parameters.limits.v_max = 10;
  sweep_params.starting_parameters.run_parameters.limits.m_limit = 5.0;
  sweep_params.starting_parameters.run_parameters.reproduction_probabilities
    .p_encounter = 0.1;
  sweep_params.starting_parameters.run_parameters.reproduction_probabilities
    .p_change = 0.2;
  sweep_params.starting_parameters.run_parameters.reproduction_parameters
    .starting_population = 100;
  sweep_params.starting_parameters.run_parameters.reproduction_parameters
    .m_const = 2.0;
  sweep_params.starting_parameters.run_parameters.reproduction_parameters
    .m_slope = 0.5;
  sweep_params.starting_parameters.run_parameters.genetic_probabilities
    .p_crossing = 0.3;
  sweep_params.starting_parameters.run_parameters.genetic_probabilities
    .p_mutation = 0.4;
  sweep_params.starting_parameters.run_parameters.allele_parameters
    .starting_allele_count = 10;
  sweep_params.starting_parameters.run_parameters.allele_parameters.v_mutation =
    1.0;
  sweep_params.starting_parameters.run_parameters.allele_parameters.v_stretch =
    1.5;
  sweep_params.starting_parameters.run_parameters.energy_parameters.e_increase =
    10.0;
  sweep_params.starting_parameters.run_parameters.energy_parameters
    .e_consumption = 1.0;
  sweep_params.starting_parameters.run_parameters.energy_parameters.e_intake =
    5.0;
  sweep_params.starting_parameters.run_parameters.energy_parameters.e_discount =
    0.9;

  sweep_params.delta.steps = 0;
  sweep_params.delta.seed = 0;
  sweep_params.delta.limits.v_min = 0;
  sweep_params.delta.limits.v_max = 0;
  sweep_params.delta.limits.m_limit = 0.0;
  sweep_params.delta.reproduction_probabilities.p_encounter = 0.0;
  sweep_params.delta.reproduction_probabilities.p_change = 0.0;
  sweep_params.delta.reproduction_parameters.starting_population = 0;
  sweep_params.delta.reproduction_parameters.m_const = 0.0;
  sweep_params.delta.reproduction_parameters.m_slope = 0.0;
  sweep_params.delta.genetic_probabilities.p_crossing = 0.0;
  sweep_params.delta.genetic_probabilities.p_mutation = 0.0;
  sweep_params.delta.allele_parameters.starting_allele_count = 0;
  sweep_params.delta.allele_parameters.v_mutation = 0.0;
  sweep_params.delta.allele_parameters.v_stretch = 0.0;
  sweep_params.delta.energy_parameters.e_increase = 0.0;
  sweep_params.delta.energy_parameters.e_consumption = 0.0;
  sweep_params.delta.energy_parameters.e_intake = 0.0;
  sweep_params.delta.energy_parameters.e_discount = 0.0;

  auto all_runs =
    fatint::simulation::fullyExpandExperimentSweepParameters(sweep_params);

  // Should have 2 experiments * 3 runs = 6 total runs
  CHECK(all_runs.size() == 6);
}
