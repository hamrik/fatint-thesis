#pragma once

#include "genetics/genetics.hpp"
#include "measurement/types.hpp"
#include "model/types.hpp"
#include <memory>

namespace fatint::measurement
{

class DepthFirstSearchSpeciesCounter : public ISpeciesCounter
{
  public:
    DepthFirstSearchSpeciesCounter(std::unique_ptr<genetics::ISimilarity> similarity);
    ~DepthFirstSearchSpeciesCounter() override = default;

    [[nodiscard]] auto count_species(const model::Population &population) const -> size_t override;

  private:
    std::unique_ptr<genetics::ISimilarity> similarity;
};

} // namespace fatint::measurement
