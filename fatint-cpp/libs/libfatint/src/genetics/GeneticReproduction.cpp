#include "genetics/GeneticReproduction.hpp"

namespace fatint::genetics {

GeneticReproduction::GeneticReproduction(IMutation& mutation,
                                         ICrossover& crossover)
  : mutation(mutation)
  , crossover(crossover)
{
}

auto
GeneticReproduction::reproduce(math::Random& random,
                               const model::GeneticProbabilities& probabilities,
                               const model::AlleleParameters& allele_parameters,
                               const model::Genotype& a,
                               const model::Genotype& b) const -> model::Entity
{
  model::Genotype child;
  child.resize(a.size());
  crossover.crossover(random, probabilities.p_crossing, a, b, child);
  mutation.mutate(
    random, probabilities.p_mutation, allele_parameters.v_mutation, child);
  return { .age = 0, .energy = 0, .genotype = child };
}

} // namespace fatint::genetics
