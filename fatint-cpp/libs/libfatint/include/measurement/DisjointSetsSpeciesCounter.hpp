#pragma once

#include "genetics/genetics.hpp"
#include "measurement/types.hpp"
#include "model/types.hpp"

namespace fatint::measurement {

class DisjointSetsSpeciesCounter : public ISpeciesCounter
{
public:
  [[nodiscard]] auto count_species(const model::Limits& limits,
                                   const genetics::ISimilarity& similarity,
                                   const model::Population& population) const
    -> size_t override;
};

} // namespace fatint::measurement
