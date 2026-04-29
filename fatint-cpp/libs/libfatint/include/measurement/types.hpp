#pragma once

#include "model/types.hpp"

namespace fatint::measurement
{

/// Common interface for algorithms that can count species making up a population.
class ISpeciesCounter
{
  public:
    virtual ~ISpeciesCounter() = default;
    [[nodiscard]] virtual auto count_species(const model::Population &population) const -> size_t = 0;
};

} // namespace fatint::measurement
