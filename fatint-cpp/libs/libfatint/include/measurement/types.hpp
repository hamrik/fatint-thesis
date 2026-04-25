#pragma once

#include "genetics/genetics.hpp"
#include "model/types.hpp"

namespace fatint::measurement
{

class ISpeciesCounter
{
  public:
    virtual ~ISpeciesCounter() = default;
    [[nodiscard]] virtual auto count_species(const model::Limits &limits, const genetics::ISimilarity &similarity,
                                             const model::Population &population) const -> size_t = 0;
};

} // namespace fatint::measurement
