#pragma once

#include "genetics/genetics.hpp"
#include "math/Random.hpp"
#include "measurement/types.hpp"
#include "model/types.hpp"
#include "simulation/Environment.hpp"
#include "simulation/types.hpp"

namespace fatint::simulation {

class Simulator
{
public:
  Simulator(genetics::ISimilarity& similarity,
            genetics::ISelection& selection,
            genetics::IReproduction& reproduction,
            genetics::IValidator& validator,
            genetics::IAlleleAdder& allele_adder,
            measurement::ISpeciesCounter& species_counter);

  RunStates run(math::Random& random, const RunParameters& params);

private:
  bool tick(math::Random& random,
            const RunParameters& params,
            Environment& environment,
            model::Population& population);
  size_t reproduce(math::Random& random,
                   const RunParameters& params,
                   model::Population& population);
  void add_allele(math::Random& random,
                  const RunParameters& params,
                  model::Population& population);
  size_t count_species(const model::Population& population);

  genetics::ISimilarity& similarity;
  genetics::ISelection& selection;
  genetics::IReproduction& reproduction;
  genetics::IValidator& validator;
  genetics::IAlleleAdder& allele_adder;
  measurement::ISpeciesCounter& species_counter;
};

} // namespace fatint::simulation
