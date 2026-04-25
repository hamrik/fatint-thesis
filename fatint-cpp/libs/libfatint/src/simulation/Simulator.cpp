#include "simulation/Simulator.hpp"

#include "genetics/genetics.hpp"
#include "model/formulas.hpp"
#include "simulation/Environment.hpp"
#include "simulation/types.hpp"

namespace fatint::simulation {

auto
random_entity(math::Random& random,
              const model::Limits& limits,
              size_t allele_count) -> model::Entity
{
  model::Entity entity;
  entity.age = 0;
  entity.energy = 0;
  for (size_t i = 0; i < allele_count; i++) {
    entity.genotype.push_back(random.random(limits.v_min, limits.v_max));
  }
  return entity;
}

Simulator::Simulator(genetics::ISimilarity& similarity,
                     genetics::ISelection& selection,
                     genetics::IReproduction& reproduction,
                     genetics::IValidator& validator,
                     genetics::IAlleleAdder& allele_adder,
                     measurement::ISpeciesCounter& species_counter)
  : similarity(similarity)
  , selection(selection)
  , reproduction(reproduction)
  , validator(validator)
  , allele_adder(allele_adder)
  , species_counter(species_counter)
{
}

auto
Simulator::run(math::Random& random, const RunParameters& params) const -> RunStates
{
  std::vector<State> states;
  states.reserve(params.steps);

  Environment environment;
  model::Population population;
  population.reserve(params.reproduction_parameters.starting_population);

  for (size_t i = 0; i < params.reproduction_parameters.starting_population;
       i++) {
    population.push_back(random_entity(
      random, params.limits, params.allele_parameters.starting_allele_count));
  }

  size_t allele_count = params.allele_parameters.starting_allele_count;

  bool keep_running = true;

  for (size_t i = 0; i < params.steps; ++i) {
    if (!keep_running) {
      states.push_back({ .entity_count=0, .allele_count=allele_count, .species_count=0 });
      continue;
    }

    environment.replenish(params.energy_parameters.e_increase);

    keep_running = tick(random, params, environment, population);
    size_t new_alleles = reproduce(random, params, population);
    allele_count += new_alleles;
    while (new_alleles--) {
      add_allele(random, params, population);
    }

    size_t species_count = count_species(params.limits, population);

    states.push_back({ .entity_count = population.size(),
                       .allele_count = allele_count,
                       .species_count = species_count });
  }

  return states;
}

auto
Simulator::tick(math::Random& random,
                const RunParameters& params,
                Environment& environment,
                model::Population& population) const -> bool
{
  for (size_t i : random.random_indices(population.size())) {
    // Iterate over population in random order to prevent older entities from
    // having an advantage to the environment.
    auto& entity = population[i];
    entity.age += 1;
    auto energy_taken = environment.take(params.energy_parameters.e_intake);
    entity.energy +=
      model::entity_energy_change(entity.age,
                                  energy_taken,
                                  params.energy_parameters.e_discount,
                                  params.energy_parameters.e_consumption);
  }
  std::erase_if(population,
                [](const model::Entity& en) { return en.energy <= 0; });
  return population.size() > 0;
}

auto
Simulator::reproduce(math::Random& random,
                     const RunParameters& params,
                     model::Population& population) const -> size_t
{
  size_t new_allele_count = 0;
  for (size_t i = 0; i < population.size(); i++) {
    if (!random.chance(params.reproduction_probabilities.p_encounter)) {
      continue;
    }
    auto mate = selection.select(random, params.limits, similarity, i, population);
    if (!mate.has_value()) {
      continue;
    }
    auto offspring = reproduction.reproduce(random,
                                            params.genetic_probabilities,
                                            params.allele_parameters,
                                            population[i].genotype,
                                            population[mate.value()].genotype);
    if (!validator.validate(params.limits, offspring.genotype)) {
      continue;
    }
    population.push_back(offspring);
    if (random.chance(params.reproduction_probabilities.p_change)) {
      new_allele_count++;
    }
  }
  return new_allele_count;
}

void
Simulator::add_allele(math::Random& random,
                      const RunParameters& params,
                      model::Population& population) const
{
  for (auto& entity : population) {
    allele_adder.add_allele(
      random, params.limits, params.allele_parameters, entity.genotype);
  }
}

auto
Simulator::count_species(const model::Limits& limits, const model::Population& population) const -> size_t
{
  return species_counter.count_species(limits, similarity, population);
}

} // namespace fatint::simulation
