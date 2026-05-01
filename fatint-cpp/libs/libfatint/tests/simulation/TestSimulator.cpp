#include "genetics/GeneticsImpl.hpp"
#include "measurement/DepthFirstSearchSpeciesCounter.hpp"
#include "simulation/Simulator.hpp"
#include "simulation/types.hpp"
#include <memory>

#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.hpp>

auto make_simulator(fatint::simulation::RunParameters params) -> std::unique_ptr<fatint::simulation::Simulator>
{
    fatint::genetics::EuclideanDistanceSimilarity similarity(params.reproduction_parameters);

    return std::make_unique<fatint::simulation::Simulator>(
        std::make_unique<fatint::genetics::EuclideanDistanceSimilarity>(similarity),
        std::make_unique<fatint::genetics::ReservoirSelection>(
            std::make_unique<fatint::genetics::EuclideanDistanceSimilarity>(similarity)),
        std::make_unique<fatint::genetics::GeneticReproduction>(
            std::make_unique<fatint::genetics::BoundedMutation>(params.genetic_probabilities.p_mutation,
                                                                params.genetic_parameters.v_mutation),
            std::make_unique<fatint::genetics::Crossover>(params.genetic_probabilities.p_crossing), params.limits.v_min,
            params.limits.v_max),
        std::make_unique<fatint::genetics::RandomGeneAdder>(params.limits.v_min, params.limits.v_max),
        std::make_unique<fatint::measurement::DepthFirstSearchSpeciesCounter>(
            std::make_unique<fatint::genetics::EuclideanDistanceSimilarity>(similarity)),
        params);
}

TEST_CASE("Simulator - entities eventually die of old age")
{
    fatint::math::Random random(0);

    fatint::simulation::RunParameters params;
    params.steps = 50;
    params.reproduction_probabilities.p_encounter = 0;

    auto simulator = make_simulator(params);

    fatint::simulation::RunStates output = simulator->run(random);
    CHECK(output[0].entity_count > 0);
    CHECK(output[1].entity_count > 0);
    CHECK(output[49].entity_count == 0);
}

TEST_CASE("Simulator - entities reproduce")
{
    fatint::math::Random random(0);

    fatint::simulation::RunParameters params;
    params.steps = 50;
    params.genetic_parameters.n_init = 1;
    params.limits.v_min = 0;
    params.limits.v_max = 100;
    params.reproduction_parameters.m_limit = 100;

    auto simulator = make_simulator(params);

    fatint::simulation::RunStates output = simulator->run(random);

    CHECK(output[0].entity_count > 0);
    CHECK(output[1].entity_count > 0);
    CHECK(output[49].entity_count > 0);
}

TEST_CASE("Simulator - simulation is deterministic")
{
    fatint::math::Random random(0);

    fatint::simulation::RunParameters params;
    params.steps = 50;
    params.genetic_parameters.n_init = 1;
    params.limits.v_min = 0;
    params.limits.v_max = 100;
    params.reproduction_parameters.m_limit = 100;

    auto simulator = make_simulator(params);

    fatint::simulation::RunStates output1 = simulator->run(random);
    random.seed(0);
    fatint::simulation::RunStates output2 = simulator->run(random);

    for (size_t i = 0; i < params.steps; i++)
    {
        CHECK(output1[i].entity_count == output2[i].entity_count);
        CHECK(output1[i].gene_count == output2[i].gene_count);
        CHECK(output1[i].species_count == output2[i].species_count);
    }
}

TEST_CASE("Simulator - gene count increases")
{
    fatint::math::Random random(0);

    fatint::simulation::RunParameters params;
    params.steps = 50;
    params.genetic_parameters.n_init = 1;
    params.limits.v_min = 0;
    params.limits.v_max = 100;
    params.reproduction_parameters.m_limit = 100;
    params.reproduction_probabilities.p_change = 0.2;

    auto simulator = make_simulator(params);
    fatint::simulation::RunStates output = simulator->run(random);

    CHECK(output[49].gene_count > 1);
}

TEST_CASE("Simulator - default params collapse to one surviving species")
{
    fatint::math::Random random(0);

    fatint::simulation::RunParameters params;
    params.steps = 2000;

    auto simulator = make_simulator(params);
    fatint::simulation::RunStates output = simulator->run(random);

    CHECK(output[999].entity_count > 0);
    CHECK(output[999].species_count == 1);
}

TEST_CASE("Simulator - P_change=0.001 encourages species proliferation")
{
    fatint::math::Random random(0);

    fatint::simulation::RunParameters params;
    params.steps = 2000;
    params.reproduction_probabilities.p_change = 0.001;

    auto simulator = make_simulator(params);
    fatint::simulation::RunStates output = simulator->run(random);

    CHECK(output[999].entity_count > 0);
    CHECK(output[999].species_count > 1);
}
