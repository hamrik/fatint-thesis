#pragma once

#include "math/types.hpp"
#include "simulation/types.hpp"

namespace fatint::math {

class StatisticsEvaluator
{
public:
  /// Computes the minimum, average and maximum of the values along with their
  /// standard deviation and error.
  Measurement measure(std::vector<double> values);

  /// Computes population, allele and species statistics across all runs per
  /// step.
  simulation::ExperimentResults measure(
    const simulation::ExperimentParameters& params,
    const simulation::ExperimentStates& results);

  /// Computes the statistics of every experiment in the sweep.
  simulation::ExperimentSweepResults measure(
    const simulation::ExperimentSweepParameters& params,
    const simulation::ExperimentSweepStates& results);
};

} // namespace fatint::math
