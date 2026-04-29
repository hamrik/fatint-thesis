#pragma once

#include "genetics/genetics.hpp"
#include "measurement/types.hpp"
#include "model/types.hpp"
#include <memory>

namespace fatint::measurement
{

class DisjointSetsSpeciesCounter : public ISpeciesCounter
{
  public:
    DisjointSetsSpeciesCounter(std::unique_ptr<genetics::ISimilarity> similarity);
    ~DisjointSetsSpeciesCounter() override = default;

    [[nodiscard]] auto count_species(const model::Population &population) const -> size_t override;

  private:
    std::unique_ptr<genetics::ISimilarity> similarity;
};

} // namespace fatint::measurement
