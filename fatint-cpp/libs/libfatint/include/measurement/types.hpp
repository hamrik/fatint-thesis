#pragma once

#include "genetics/genetics.hpp"
#include "model/types.hpp"

namespace fatint::measurement {

class ISpeciesCounter
{
public:
  virtual ~ISpeciesCounter() = default;
  virtual size_t count_species(const genetics::ISimilarity& similarity,
                               const model::Population& population) const = 0;
};

} // namespace fatint::measurement