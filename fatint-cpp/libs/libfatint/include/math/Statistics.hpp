#pragma once

#include "math/types.hpp"
#include "simulation/types.hpp"

namespace fatint::math
{

/// Computes the minimum, average and maximum of the values along with their
/// standard deviation and error.
auto measure(const std::vector<double> &values) -> Measurement;

/// Computes population, allele and species statistics across all runs per
/// step.
auto measure(size_t runs, size_t steps, const simulation::ExperimentStates &results) -> simulation::ExperimentResults;

/// Computes population, allele and species statistics across all runs per
/// step.
auto measure(const simulation::ExperimentParameters &params, const simulation::ExperimentStates &results)
    -> simulation::ExperimentResults;

/// Computes the statistics of every experiment in the sweep.
auto measure(const simulation::ExperimentSweepParameters &params, const simulation::ExperimentSweepStates &results)
    -> simulation::ExperimentSweepResults;

/// Computes the statistics of every experiment in the sweep.
auto measure(const simulation::ExperimentSweepParameters &params, const simulation::ExperimentStates &results)
    -> simulation::ExperimentSweepResults;

} // namespace fatint::math
