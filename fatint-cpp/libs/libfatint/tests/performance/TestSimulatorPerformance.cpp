#include "genetics/GeneticReproduction.hpp"
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

    [[nodiscard]] auto count_species(const fatint::model::Limits &limits,
                                     const fatint::genetics::ISimilarity &similarity,
                                     const fatint::model::Population &population) const -> size_t override
    {
        return 1;
    }
};

auto measure_no_churn(size_t sz) -> double
{
    const size_t STEPS = 1000;
    fatint::math::Random random(0);
    fatint::simulation::RunParameters params;
    params.steps = STEPS;
    params.reproduction_parameters.starting_population = sz;
    params.reproduction_probabilities.p_encounter = 0;
    params.energy_parameters.e_consumption = 0;
    params.limits.m_limit = 0;
    params.energy_parameters.e_increase = static_cast<double>(sz) * params.energy_parameters.e_intake;

    fatint::genetics::SimilarityImpl similarity;
    fatint::genetics::SelectionImpl selection;
    fatint::genetics::MutationImpl mutation;
    fatint::genetics::CrossoverImpl crossover;
    fatint::genetics::GeneticReproduction reproduction(mutation, crossover);
    fatint::genetics::ValidatorImpl validator;
    fatint::genetics::RandomAlleleAdder allele_adder;
    DummySpeciesCounter species_counter;

    fatint::simulation::Simulator simulator(similarity, selection, reproduction, validator, allele_adder,
                                            species_counter);

    auto before = std::chrono::high_resolution_clock::now();
    fatint::simulation::RunStates output = simulator.run(random, params);
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

    fatint::genetics::SimilarityImpl similarity;
    fatint::genetics::SelectionImpl selection;
    fatint::genetics::MutationImpl mutation;
    fatint::genetics::CrossoverImpl crossover;
    fatint::genetics::GeneticReproduction reproduction(mutation, crossover);
    fatint::genetics::ValidatorImpl validator;
    fatint::genetics::RandomAlleleAdder allele_adder;
    DummySpeciesCounter species_counter;

    fatint::simulation::Simulator simulator(similarity, selection, reproduction, validator, allele_adder,
                                            species_counter);

    auto before = std::chrono::high_resolution_clock::now();
    fatint::simulation::RunStates output = simulator.run(random, params);
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
