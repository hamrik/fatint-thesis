#pragma once

#include "genetics/genetics.hpp"

namespace fatint::genetics {

class GeneticReproduction : public IReproduction
{
public:
  GeneticReproduction(IMutation& mutation, ICrossover& crossover);

  model::Entity reproduce(math::Random& random,
                          const model::GeneticProbabilities& probabilities,
                          const model::AlleleParameters& allele_parameters,
                          const model::Genotype& a,
                          const model::Genotype& b) const override;

private:
  const IMutation& mutation;
  const ICrossover& crossover;
};

} // namespace fatint::genetics
