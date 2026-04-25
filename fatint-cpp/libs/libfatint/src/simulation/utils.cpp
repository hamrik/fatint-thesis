#include "simulation/utils.hpp"

#include "model/utils.hpp"
#include "simulation/types.hpp"

namespace fatint::simulation
{

auto operator+=(RunParameters &a, const RunParameters &b) -> RunParameters &
{
    a.limits += b.limits;
    a.reproduction_probabilities += b.reproduction_probabilities;
    a.reproduction_parameters += b.reproduction_parameters;
    a.genetic_probabilities += b.genetic_probabilities;
    a.allele_parameters += b.allele_parameters;
    a.energy_parameters += b.energy_parameters;
    return a;
}

auto ExperimentParameters::expand() const -> std::vector<RunParameters>
{
    std::vector<RunParameters> result;
    RunParameters run_params{run_parameters};
    for (size_t i = 0; i < runs; i++)
    {
        result.emplace_back(run_params);
        run_params.seed++;
    }
    return result;
}

auto ExperimentSweepParameters::expand() const -> std::vector<RunParameters>
{
    std::vector<RunParameters> result;
    ExperimentParameters exp_params{starting_parameters};
    for (size_t e = 0; e < experiments; e++)
    {
        auto run_params = exp_params.expand();
        result.insert(result.end(), run_params.begin(), run_params.end());
        exp_params.run_parameters += delta;
    }
    return result;
}

} // namespace fatint::simulation
