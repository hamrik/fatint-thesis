/**
 * @file utils.hpp
 * @brief Utilities and operators for working with simulation parameters
 */
#pragma once

#include "model/types.hpp"

namespace fatint::model {

auto
operator+=(Limits& a, const Limits& b) -> Limits&;
auto
operator+=(ReproductionProbabilities& a, const ReproductionProbabilities& b)
  -> ReproductionProbabilities&;
auto
operator+=(ReproductionParameters& a, const ReproductionParameters& b)
  -> ReproductionParameters&;
auto
operator+=(GeneticProbabilities& a, const GeneticProbabilities& b)
  -> GeneticProbabilities&;
auto
operator+=(AlleleParameters& a, const AlleleParameters& b) -> AlleleParameters&;
auto
operator+=(EnergyParameters& a, const EnergyParameters& b) -> EnergyParameters&;

} // namespace fatint::model
