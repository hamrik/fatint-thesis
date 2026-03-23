/**
 * @file types.hpp
 * @brief The public input and output types of the simulation.
 */

#pragma once

#include <cstddef>
#include <vector>

#include "math/types.hpp"
#include "model/types.hpp"

namespace fatint::simulation {

/// Starting parameters of a run.
///
struct RunParameters
{
  /// Maximum number of steps per run.
  size_t steps;
  /// Random seed of the run.
  size_t seed;

  /// Value bounds,
  model::Limits limits;
  /// Reproduction-related probabilities.
  model::ReproductionProbabilities reproduction_probabilities;
  /// Reproduction-related parameters.
  model::ReproductionParameters reproduction_parameters;
  /// Genetic algorithm probabilities.
  model::GeneticProbabilities genetic_probabilities;
  /// Genetic algorithm parameters.
  model::AlleleParameters allele_parameters;
  /// Energy parameters.
  model::EnergyParameters energy_parameters;
};

/// Starting parameters of an experiment.
///
struct ExperimentParameters
{
  /// Common starting parameters of all runs.
  /// The seed is incremented between runs.
  RunParameters run_parameters;
  /// Number of runs with the same parameters.
  int runs;
};

/// Parameters of multiple experiments.
/// The starting parameters are incremented by the delta for each experiment.
///
struct ExperimentSweepParameters
{
  /// The starting parameters of the experiments.
  /// The seed is reset between experiments.
  ExperimentParameters starting_parameters;
  /// The parameters are incremented by this value for each experiment.
  RunParameters delta;
  /// The number of experiments to run.
  size_t experiments;
};

/// The current state of a single run.
///
struct State
{
  /// Number of entities alive.
  size_t entity_count;
  /// Number of alleles in any gene.
  size_t allele_count;
  /// Number of genetically distinct species.
  size_t species_count;
};

/// Statistics of a single step across all runs.
///
struct Statistics
{
  math::Measurement entity_count;
  std::vector<double> entity_count_values;
  math::Measurement allele_count;
  std::vector<double> allele_count_values;
  math::Measurement species_count;
  std::vector<double> species_count_values;
};

/// States of all steps of a single run.
///
using RunStates = std::vector<State>;

/// States of all steps of all runs.
///
using ExperimentStates = std::vector<RunStates>;

/// Statistics of all steps across all runs.
///
using ExperimentResults = std::vector<Statistics>;

/// The final states of an experiment sweep.
///
using ExperimentSweepStates = std::vector<ExperimentStates>;

/// The final statistics of an experiment sweep.
///
using ExperimentSweepResults = std::vector<ExperimentResults>;

}

std::ostream&
operator<<(std::ostream& os, const fatint::simulation::RunParameters& params);