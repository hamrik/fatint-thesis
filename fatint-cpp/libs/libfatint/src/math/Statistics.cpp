#include "math/Statistics.hpp"

#include <cassert>
#include <cmath>
#include <stdexcept>

#include "simulation/types.hpp"
#include "simulation/utils.hpp"

namespace fatint::math {

using namespace simulation;

auto
StatisticsEvaluator::measure(std::vector<double> values) -> Measurement
{
  assert(values.size() > 0);

  double min = values[0];
  double max = values[0];
  double sum = 0;
  double inner_product = 0;

  for (double value : values) {
    min = std::min(min, value);
    max = std::max(max, value);
    sum += value;
    inner_product += value * value;
  }

  double average = sum / static_cast<double>(values.size());

  double sample_variance =
    inner_product / static_cast<double>(values.size()) - 1.0;

  return { .min = min,
           .max = max,
           .avg = average,
           .std = std::sqrt(sample_variance),
           .err = std::sqrt(sample_variance) / std::sqrt(values.size()) };
}

auto
StatisticsEvaluator::measure(const ExperimentParameters& params,
                             const ExperimentStates& results)
  -> ExperimentResults
{
  ExperimentResults statistics;

  if(results.size() != params.runs) {
    throw std::runtime_error{"Result count and run count does not match"};
  }
  for (const auto& result : results) {
    if(result.size() != params.run_parameters.steps) {
      throw std::runtime_error{"Row count and step count does not match"};
    }
  }

  for (size_t step = 0; step < params.run_parameters.steps; step++) {
    std::vector<double> entity_count;
    std::vector<double> allele_count;
    std::vector<double> species_count;
    entity_count.reserve(params.runs);
    allele_count.reserve(params.runs);
    species_count.reserve(params.runs);
    for (size_t run = 0; run < params.runs; run++) {
      entity_count.push_back(
        static_cast<double>(results[run][step].entity_count));
      allele_count.push_back(
        static_cast<double>(results[run][step].allele_count));
      species_count.push_back(
        static_cast<double>(results[run][step].species_count));
    }
    statistics.push_back({ .entity_count = measure(entity_count),
                           .entity_count_values = entity_count,
                           .allele_count = measure(allele_count),
                           .allele_count_values = allele_count,
                           .species_count = measure(species_count),
                           .species_count_values = species_count });
  }

  return statistics;
}

auto
StatisticsEvaluator::measure(const ExperimentSweepParameters& params,
                             const ExperimentSweepStates& results)
  -> ExperimentSweepResults
{
  ExperimentSweepResults sweep_results;

  RunParameters current_params = params.starting_parameters.run_parameters;
  for (const auto& result : results) {
    ExperimentParameters current_experiment_params;
    current_experiment_params.run_parameters = current_params;
    current_experiment_params.runs = params.starting_parameters.runs;

    ExperimentResults statistics = measure(current_experiment_params, result);
    sweep_results.push_back(statistics);

    current_params += params.delta;
  }

  return sweep_results;
}

} // namespace fatint::math
