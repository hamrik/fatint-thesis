#include "math/Statistics.hpp"

#include <cassert>
#include <cmath>
#include <stdexcept>

#include "simulation/types.hpp"
#include "simulation/utils.hpp"

namespace fatint::math
{

using namespace simulation;

auto measure(const std::vector<double> &values) -> Measurement
{
    assert(values.size() > 0);

    double min = values[0];
    double max = values[0];
    double sum = 0;

    for (double value : values)
    {
        min = std::min(min, value);
        max = std::max(max, value);
        sum += value;
    }

    double average = sum / static_cast<double>(values.size());

    double variance = 0;
    for (double value : values)
    {
        variance += (value - average) * (value - average);
    }

    auto bessel_correction = static_cast<double>(values.size() - 1);
    auto srn = std::sqrt(static_cast<double>(values.size()));

    double standard_deviation = std::sqrt(variance / bessel_correction);

    return {.min = min, .max = max, .avg = average, .std = standard_deviation, .err = standard_deviation / srn};
}

auto measure(size_t runs, size_t steps, const ExperimentStates &results) -> ExperimentResults
{
    ExperimentResults statistics;

    if (results.size() != runs)
    {
        throw std::runtime_error{"Result count and run count does not match"};
    }
    for (const auto &result : results)
    {
        if (result.size() != steps)
        {
            throw std::runtime_error{"Row count and step count does not match"};
        }
    }

    for (size_t step = 0; step < steps; step++)
    {
        std::vector<double> entity_count;
        std::vector<double> allele_count;
        std::vector<double> species_count;
        entity_count.reserve(runs);
        allele_count.reserve(runs);
        species_count.reserve(runs);
        for (size_t run = 0; run < runs; run++)
        {
            entity_count.push_back(static_cast<double>(results[run][step].entity_count));
            allele_count.push_back(static_cast<double>(results[run][step].allele_count));
            species_count.push_back(static_cast<double>(results[run][step].species_count));
        }
        statistics.push_back({.entity_count = measure(entity_count),
                              .entity_count_values = entity_count,
                              .allele_count = measure(allele_count),
                              .allele_count_values = allele_count,
                              .species_count = measure(species_count),
                              .species_count_values = species_count});
    }

    return statistics;
}

auto measure(const ExperimentParameters &params, const ExperimentStates &results) -> ExperimentResults
{
    return measure(params.runs, params.run_parameters.steps, results);
}

auto measure(const ExperimentSweepParameters &params, const ExperimentSweepStates &results) -> ExperimentSweepResults
{
    ExperimentSweepResults sweep_results;
    size_t runs = params.starting_parameters.runs;
    size_t steps = params.starting_parameters.run_parameters.steps;

    for (const auto &result : results)
    {
        ExperimentResults statistics = measure(runs, steps, result);
        sweep_results.push_back(statistics);
    }

    return sweep_results;
}

auto measure(const ExperimentSweepParameters &params, const ExperimentStates &results) -> ExperimentSweepResults
{
    ExperimentSweepResults sweep_results;
    size_t experiments = params.experiments;
    size_t runs = params.starting_parameters.runs;
    size_t steps = params.starting_parameters.run_parameters.steps;

    for (size_t i = 0; i < experiments; i++)
    {
        ExperimentStates result(results.begin() + static_cast<long>(i * runs),
                                results.begin() + static_cast<long>((i + 1) * runs));
        ExperimentResults statistics = measure(runs, steps, result);
        sweep_results.push_back(statistics);
    }

    return sweep_results;
}

} // namespace fatint::math
