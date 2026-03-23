#include "simulation/utils.hpp"

#include "model/utils.hpp"
#include "simulation/types.hpp"

namespace fatint::simulation {

auto
operator+=(RunParameters& a, const RunParameters& b) -> RunParameters&
{
  a.limits += b.limits;
  a.reproduction_probabilities += b.reproduction_probabilities;
  a.reproduction_parameters += b.reproduction_parameters;
  a.genetic_probabilities += b.genetic_probabilities;
  a.allele_parameters += b.allele_parameters;
  a.energy_parameters += b.energy_parameters;
  return a;
}

auto
expandExperimentParameters(const ExperimentParameters& params)
  -> std::vector<RunParameters>
{
  std::vector<RunParameters> result;
  RunParameters run_params{ params.run_parameters };
  for (size_t i = 0; i < params.runs; i++) {
    result.push_back(RunParameters{ run_params });
    run_params.seed++;
  }
  return result;
}

auto
expandExperimentSweepParameters(const ExperimentSweepParameters& params)
  -> std::vector<ExperimentParameters>
{
  std::vector<ExperimentParameters> result;
  ExperimentParameters exp_params{ params.starting_parameters };
  for (size_t e = 0; e < params.experiments; e++) {
    result.push_back(ExperimentParameters{ exp_params });
    exp_params.run_parameters += params.delta;
  }
  return result;
}

auto
fullyExpandExperimentSweepParameters(const ExperimentSweepParameters& params)
  -> std::vector<RunParameters>
{
  std::vector<RunParameters> result;
  ExperimentParameters exp_params{ params.starting_parameters };
  for (size_t e = 0; e < params.experiments; e++) {
    auto run_params = expandExperimentParameters(exp_params);
    result.insert(result.end(), run_params.begin(), run_params.end());
    exp_params.run_parameters += params.delta;
  }
  return result;
}

} // namespace fatint::simulation
