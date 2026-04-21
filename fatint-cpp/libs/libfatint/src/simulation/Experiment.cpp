#include "simulation/Experiment.hpp"

#include <algorithm>
#include <execution>
#include <iostream>

#include "genetics/genetics.hpp"
#include "simulation/Simulator.hpp"
#include "simulation/utils.hpp"

namespace fatint::simulation {

Experiment::Experiment(ExperimentParameters parameters,
                       genetics::ISimilarity& similarity,
                       genetics::ISelection& selection,
                       genetics::IReproduction& reproduction,
                       genetics::IValidator& validator,
                       genetics::IAlleleAdder& allele_adder,
                       measurement::ISpeciesCounter& species_counter)
  : parameters(parameters)
  , similarity(similarity)
  , selection(selection)
  , reproduction(reproduction)
  , validator(validator)
  , allele_adder(allele_adder)
  , species_counter(species_counter)
{
}

auto
Experiment::run() -> ExperimentStates
{
  Simulator simulator(similarity,
                      selection,
                      reproduction,
                      validator,
                      allele_adder,
                      species_counter);

  std::vector<RunParameters> run_params =
    expandExperimentParameters(parameters);
  ExperimentStates results;
  results.resize(run_params.size());
  std::transform(std::execution::par_unseq,
                 run_params.begin(),
                 run_params.end(),
                 results.begin(),
                 [&simulator](const RunParameters& params) {
                   math::Random random;
                   random.seed(params.seed);
                   return simulator.run(random, params);
                 });

  return results;
}

ExperimentSweep::ExperimentSweep(ExperimentSweepParameters parameters,
                                 genetics::ISimilarity& similarity,
                                 genetics::ISelection& selection,
                                 genetics::IReproduction& reproduction,
                                 genetics::IValidator& validator,
                                 genetics::IAlleleAdder& allele_adder,
                                 measurement::ISpeciesCounter& species_counter)
  : parameters(parameters)
  , similarity(similarity)
  , selection(selection)
  , reproduction(reproduction)
  , validator(validator)
  , allele_adder(allele_adder)
  , species_counter(species_counter)
{
}

auto
ExperimentSweep::run() -> ExperimentSweepStates
{
  std::cerr << "Running " << parameters.experiments << " experiments, "
            << parameters.starting_parameters.runs << " runs per experiment, "
            << parameters.starting_parameters.run_parameters.steps
            << " steps per run" << "\n";
  std::cerr.flush();

  ExperimentSweepStates results;
  ExperimentParameters exp_params(parameters.starting_parameters);
  for (size_t i = 0; i < parameters.experiments; i++) {
    Experiment exp(exp_params,
                   similarity,
                   selection,
                   reproduction,
                   validator,
                   allele_adder,
                   species_counter);
    ExperimentStates run_results = exp.run();
    results.push_back(run_results);
    exp_params.run_parameters += parameters.delta;
  }
  return results;
}

} // namespace fatint::simulation
