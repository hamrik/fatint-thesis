#pragma once

#include "simulation/types.hpp"

namespace fatint::math
{

/// Statistical properties of the same point in time across multiple simulations
struct Measurement
{
    double min;
    double max;
    double avg;
    double std;
    double err;
};

/// Statistics of a single step across all runs.
///
struct Statistics
{
    Measurement entity_count;
    std::vector<double> entity_count_values;
    Measurement gene_count;
    std::vector<double> gene_count_values;
    Measurement species_count;
    std::vector<double> species_count_values;
};

/// Statistics of all steps across all runs.
///
using ExperimentStatistics = std::vector<Statistics>;

/// The final statistics of an experiment sweep.
///
using ExperimentSweepStatistics = std::vector<ExperimentStatistics>;

/// Computes the minimum, average and maximum of the values along with their
/// standard deviation and error.
auto measure(const std::vector<double> &values) -> Measurement;

/// Computes population, gene and species count statistics across all runs per
/// step.
auto measure(size_t runs, size_t steps, const simulation::ExperimentStates &results) -> ExperimentStatistics;

/// Computes population, gene and species count statistics across all runs per
/// step.
auto measure(const simulation::ExperimentParameters &params, const simulation::ExperimentStates &results)
    -> ExperimentStatistics;

/// Computes the statistics of every experiment in the sweep.
auto measure(const simulation::ExperimentSweepParameters &params, const simulation::ExperimentSweepStates &results)
    -> ExperimentSweepStatistics;

/// Computes the statistics of every experiment in the sweep.
auto measure(const simulation::ExperimentSweepParameters &params, const simulation::ExperimentStates &results)
    -> ExperimentSweepStatistics;

} // namespace fatint::math
