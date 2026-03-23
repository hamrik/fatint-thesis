#pragma once

#include "simulation/types.hpp"

namespace fatint::simulation {

RunParameters&
operator+=(RunParameters& a, const RunParameters& b);

std::vector<RunParameters>
expandExperimentParameters(const ExperimentParameters& params);

std::vector<ExperimentParameters>
expandExperimentSweepParameters(const ExperimentSweepParameters& params);

std::vector<RunParameters>
fullyExpandExperimentSweepParameters(const ExperimentSweepParameters& params);

} // namespace fatint::simulation
