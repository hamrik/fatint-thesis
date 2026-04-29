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
    Simulator(std::unique_ptr<genetics::ISimilarity> similarity, std::unique_ptr<genetics::ISelection> selection,
              std::unique_ptr<genetics::IReproduction> reproduction, std::unique_ptr<genetics::IGeneAdder> gene_adder,
              std::unique_ptr<measurement::ISpeciesCounter> species_counter,
              RunParameters params);

    auto run(math::Random &random) const -> RunStates;

  private:
    auto tick(math::Random &random, Environment &environment, model::Population &population) const -> bool;
    auto reproduce(math::Random &random, model::Population &population) const -> size_t;
    void add_gene(math::Random &random, model::Population &population) const;
    [[nodiscard]] auto count_species(const model::Population &population) const -> size_t;

    RunParameters params;

    std::unique_ptr<genetics::ISimilarity> similarity;
    std::unique_ptr<genetics::ISelection> selection;
    std::unique_ptr<genetics::IReproduction> reproduction;
    std::unique_ptr<genetics::IGeneAdder> gene_adder;
    std::unique_ptr<measurement::ISpeciesCounter> species_counter;
};

} // namespace fatint::simulation
