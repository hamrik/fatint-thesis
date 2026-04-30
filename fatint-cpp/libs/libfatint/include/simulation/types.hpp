/**
 * @file types.hpp
 * @brief The public input and output types of the simulation.
 */

#pragma once

#include <cstddef>
#include <vector>

#include "model/types.hpp"

namespace fatint::simulation
{

/// Starting parameters of a run.
///
struct RunParameters
{
    /// Maximum number of steps per run.
    size_t steps{};
    /// Random seed of the run.
    size_t seed{};

    /// Value bounds,
    model::Limits limits;
    /// Reproduction-related probabilities.
    model::ReproductionProbabilities reproduction_probabilities;
    /// Reproduction-related parameters.
    model::ReproductionParameters reproduction_parameters;
    /// Genetic algorithm probabilities.
    model::GeneticProbabilities genetic_probabilities;
    /// Genetic algorithm parameters.
    model::GeneticParameters genetic_parameters;
    /// Energy parameters.
    model::EnergyParameters energy_parameters;

    void validate();
};

/// Starting parameters of an experiment.
///
struct ExperimentParameters
{
    /// Common starting parameters of all runs.
    /// The seed is incremented between runs.
    RunParameters run_parameters;
    /// Number of runs with the same parameters.
    size_t runs{};

    [[nodiscard]] auto expand() const -> std::vector<RunParameters>;

    void validate();
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
    size_t experiments{};

    [[nodiscard]] auto expand() const -> std::vector<RunParameters>;

    void validate();
};

/// The current state of a single run.
///
struct State
{
    /// Number of entities alive.
    size_t entity_count;
    /// Number of genes in entities' genotypes.
    size_t gene_count;
    /// Number of genetically distinct species.
    size_t species_count;
};

/// States of all steps of a single run.
///
using RunStates = std::vector<State>;

/// States of all steps of all runs.
///
using ExperimentStates = std::vector<RunStates>;

/// The final states of an experiment sweep.
///
using ExperimentSweepStates = std::vector<ExperimentStates>;

auto operator+=(RunParameters &a, const RunParameters &b) -> RunParameters &;

} // namespace fatint::simulation

auto operator<<(std::ostream &os, const fatint::simulation::RunParameters &params) -> std::ostream &;
