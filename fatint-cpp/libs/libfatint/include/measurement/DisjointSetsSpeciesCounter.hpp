#pragma once

#include "genetics/genetics.hpp"
#include "measurement/types.hpp"
#include "model/types.hpp"

namespace fatint::measurement {

class DisjointSetsSpeciesCounter : public ISpeciesCounter
{
public:
  size_t count_species(const model::Limits& limits,
                       const genetics::ISimilarity& similarity,
                       const model::Population& population) const override;
};

} // namespace fatint::measurement
