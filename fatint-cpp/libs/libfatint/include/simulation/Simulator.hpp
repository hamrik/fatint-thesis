#pragma once

#include "genetics/genetics.hpp"
#include "math/Random.hpp"
#include "measurement/types.hpp"
#include "model/types.hpp"
#include "simulation/Environment.hpp"
#include "simulation/types.hpp"

namespace fatint::simulation
{

class Simulator
{
  public:
    Simulator(genetics::ISimilarity &similarity, genetics::ISelection &selection, genetics::IReproduction &reproduction,
              genetics::IValidator &validator, genetics::IAlleleAdder &allele_adder,
              measurement::ISpeciesCounter &species_counter);

    auto run(math::Random &random, const RunParameters &params) const -> RunStates;

  private:
    auto tick(math::Random &random, const RunParameters &params, Environment &environment,
              model::Population &population) const -> bool;
    auto reproduce(math::Random &random, const RunParameters &params, model::Population &population) const -> size_t;
    void add_allele(math::Random &random, const RunParameters &params, model::Population &population) const;
    [[nodiscard]] auto count_species(const model::Limits &limits, const model::Population &population) const -> size_t;

    const genetics::ISimilarity &similarity;
    const genetics::ISelection &selection;
    const genetics::IReproduction &reproduction;
    const genetics::IValidator &validator;
    const genetics::IAlleleAdder &allele_adder;
    const measurement::ISpeciesCounter &species_counter;
};

} // namespace fatint::simulation
