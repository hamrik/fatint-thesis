#include "genetics/GeneticsImpl.hpp"
#include "simulation/Simulator.hpp"
#include "simulation/types.hpp"

#include <chrono>
#include <iostream>

#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.hpp>

const size_t STARTING_SIZE = 16;
const size_t SIZES = 8;
const size_t RUNS = 3;

const auto NS_IN_MS = 1e6;

class DummySpeciesCounter : public fatint::measurement::ISpeciesCounter
{

    [[nodiscard]] auto count_species(const fatint::model::Population &population) const -> size_t override
    {
        return 1;
    }
};

auto make_simulator(fatint::simulation::RunParameters params) -> std::unique_ptr<fatint::simulation::Simulator>
{
    fatint::genetics::EuclideanDistanceSimilarity similarity(
        params.reproduction_parameters
    );
    return std::make_unique<fatint::simulation::Simulator>(
        std::make_unique<fatint::genetics::EuclideanDistanceSimilarity>(similarity),
        std::make_unique<fatint::genetics::ReservoirSelection>(
            std::make_unique<fatint::genetics::EuclideanDistanceSimilarity>(similarity)
        ),
        std::make_unique<fatint::genetics::GeneticReproduction>(
            std::make_unique<fatint::genetics::BoundedMutation>(params.genetic_probabilities.p_mutation, params.genetic_parameters.v_mutation),
            std::make_unique<fatint::genetics::Crossover>(params.genetic_probabilities.p_crossing),
            params.limits.v_min,
            params.limits.v_max
        ),
        std::make_unique<fatint::genetics::RandomGeneAdder>(
            params.limits.v_min,
            params.limits.v_max
        ),
        std::make_unique<DummySpeciesCounter>(),
        params
    );
}

auto measure_no_churn(size_t sz) -> double
{
    const size_t STEPS = 1000;
    fatint::math::Random random(0);
    fatint::simulation::RunParameters params;
    params.steps = STEPS;
    params.reproduction_parameters.m_init = sz;
    params.reproduction_probabilities.p_encounter = 0;
    params.energy_parameters.e_consumption = 0;
    params.reproduction_parameters.m_limit = 0;
    params.energy_parameters.e_increase = static_cast<double>(sz) * params.energy_parameters.e_intake;

    auto simulator = make_simulator(params);

    auto before = std::chrono::high_resolution_clock::now();
    fatint::simulation::RunStates output = simulator->run(random);
    auto after = std::chrono::high_resolution_clock::now();
    CHECK(sz == output[output.size() - 1].entity_count);

    auto dur = std::chrono::duration_cast<std::chrono::nanoseconds>(after - before);
    return static_cast<double>(dur.count()) / NS_IN_MS;
}

auto measure_churn(size_t sz) -> double
{
    const size_t STEPS = 1000;
    fatint::math::Random random(0);
    fatint::simulation::RunParameters params;
    params.steps = STEPS;
    params.energy_parameters.e_increase = static_cast<double>(sz);

    auto simulator = make_simulator(params);

    auto before = std::chrono::high_resolution_clock::now();
    fatint::simulation::RunStates output = simulator->run(random);
    auto after = std::chrono::high_resolution_clock::now();
    CHECK(STEPS == output.size());

    auto dur = std::chrono::duration_cast<std::chrono::nanoseconds>(after - before);
    return static_cast<double>(dur.count()) / NS_IN_MS;
}

TEST_CASE("SimulatorPerformance - No churn")
{
    for (size_t sz = STARTING_SIZE, i = 0; i < SIZES; sz *= 2, i++)
    {
        double total = 0.0;
        for (size_t r = 0; r < RUNS; r++)
        {
            total += measure_no_churn(sz);
        }
        std::cout << sz << "," << (total / RUNS) << "\n";
    }
}

TEST_CASE("SimulatorPerformance - Churn")
{
    for (size_t sz = STARTING_SIZE, i = 0; i < SIZES; sz *= 2, i++)
    {
        double total = 0.0;
        for (size_t r = 0; r < RUNS; r++)
        {
            total += measure_churn(sz);
        }
        std::cout << sz << "," << (total / RUNS) << "\n";
    }
}
