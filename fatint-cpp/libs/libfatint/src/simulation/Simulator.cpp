#include "simulation/Simulator.hpp"

#include "genetics/genetics.hpp"
#include "model/formulas.hpp"
#include "model/types.hpp"
#include "simulation/Environment.hpp"
#include "simulation/types.hpp"

namespace fatint::simulation
{

auto random_entity(math::Random &random, const model::Limits &limits, size_t gene_count) -> model::Entity
{
    model::Entity entity;
    entity.age = 0;
    entity.energy = 0;
    for (size_t i = 0; i < gene_count; i++)
    {
        entity.genotype.push_back(random.random(limits.v_min, limits.v_max));
    }
    return entity;
}

Simulator::Simulator(std::unique_ptr<genetics::ISimilarity> similarity, std::unique_ptr<genetics::ISelection> selection,
                     std::unique_ptr<genetics::IReproduction> reproduction,
                     std::unique_ptr<genetics::IGeneAdder> gene_adder,
                     std::unique_ptr<measurement::ISpeciesCounter> species_counter, RunParameters params)
    : params(params), similarity(std::move(similarity)), selection(std::move(selection)),
      reproduction(std::move(reproduction)), gene_adder(std::move(gene_adder)),
      species_counter(std::move(species_counter))
{
}

auto Simulator::run(math::Random &random) const -> RunStates
{
    std::vector<State> states;
    states.reserve(params.steps);

    Environment environment;
    model::Population population;
    population.reserve(params.reproduction_parameters.m_init);

    size_t gene_count = params.genetic_parameters.n_init;

    for (size_t i = 0; i < params.reproduction_parameters.m_init; i++)
    {
        population.push_back(random_entity(random, params.limits, gene_count));
    }

    bool keep_running = true;

    for (size_t i = 0; i < params.steps; ++i)
    {
        if (!keep_running)
        {
            states.push_back({.entity_count = 0, .gene_count = gene_count, .species_count = 0});
            continue;
        }

        environment.replenish(params.energy_parameters.e_increase);

        keep_running = tick(random, environment, population);
        size_t new_genes = reproduce(random, population);
        gene_count += new_genes;
        while (new_genes--)
        {
            add_gene(random, population);
        }

        size_t species_count = count_species(population);

        states.push_back({.entity_count = population.size(), .gene_count = gene_count, .species_count = species_count});
    }

    return states;
}

auto Simulator::tick(math::Random &random, Environment &environment, model::Population &population) const -> bool
{
    for (size_t i : random.random_indices(population.size()))
    {
        // Iterate over population in random order to prevent older entities from having an advantage to the
        // environment.
        auto &entity = population[i];
        entity.age += 1;
        auto energy_taken = environment.take(params.energy_parameters.e_intake);
        entity.energy += model::entity_energy_change(entity.age, energy_taken, params.energy_parameters.e_discount,
                                                     params.energy_parameters.e_consumption);
    }
    std::erase_if(population, [](const model::Entity &en) -> bool { return en.energy <= 0; });
    return population.size() > 0;
}

auto Simulator::reproduce(math::Random &random, model::Population &population) const -> size_t
{
    size_t new_gene_count = 0;
    for (size_t i = 0; i < population.size(); i++)
    {
        if (!random.chance(params.reproduction_probabilities.p_encounter))
        {
            continue;
        }
        auto mate = selection->select(random, population, i);
        if (!mate.has_value())
        {
            continue;
        }
        auto a = population[i];
        auto b = population[mate.value()];
        size_t offspring_count = similarity->offspring_count(a, b);
        while (offspring_count--)
        {
            model::Entity offspring;
            offspring.genotype.resize(a.genotype.size());
            bool viable = reproduction->reproduce(random, a, b, offspring);
            if (!viable)
            {
                continue;
            }
            population.push_back(offspring);
            if (random.chance(params.reproduction_probabilities.p_change))
            {
                new_gene_count++;
            }
        }
    }
    return new_gene_count;
}

void Simulator::add_gene(math::Random &random, model::Population &population) const
{
    for (auto &entity : population)
    {
        gene_adder->add_gene(random, entity.genotype);
    }
}

auto Simulator::count_species(const model::Population &population) const -> size_t
{
    return species_counter->count_species(population);
}

} // namespace fatint::simulation
