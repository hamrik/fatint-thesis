#pragma once

#include "math/Random.hpp"
#include "model/types.hpp"

#include <optional>

namespace fatint::genetics {

class ISimilarity
{
public:
  virtual ~ISimilarity() = default;
  [[nodiscard]] virtual auto compatible(const model::Limits& limits,
                                        const model::Genotype& a,
                                        const model::Genotype& b) const
    -> bool = 0;
};

class ISelection
{
public:
  virtual ~ISelection() = default;

  virtual auto select(math::Random& random,
                      const model::Limits& limits,
                      const ISimilarity& similarity,
                      size_t index,
                      const model::Population& entities) const
    -> std::optional<size_t> = 0;
};

class IMutation
{
public:
  virtual ~IMutation() = default;
  virtual void mutate(math::Random& random,
                      double p_mutation,
                      int v_mutation,
                      model::Genotype& genotype) const = 0;
};

class ICrossover
{
public:
  virtual ~ICrossover() = default;
  virtual void crossover(math::Random& random,
                         double p_crossing,
                         const model::Genotype& a,
                         const model::Genotype& b,
                         model::Genotype& out) const = 0;
};

class IReproduction
{
public:
  virtual ~IReproduction() = default;
  virtual auto reproduce(math::Random& random,
                         const model::GeneticProbabilities& probabilities,
                         const model::AlleleParameters& allele_parameters,
                         const model::Genotype& a,
                         const model::Genotype& b) const -> model::Entity = 0;
};

class IValidator
{
public:
  virtual ~IValidator() = default;
  [[nodiscard]] virtual auto validate(const model::Limits& limits,
                                      const model::Genotype& genotype) const
    -> bool = 0;
};

class IAlleleAdder
{
public:
  virtual ~IAlleleAdder() = default;
  virtual void add_allele(math::Random& random,
                          const model::Limits& limits,
                          const model::AlleleParameters& parameters,
                          model::Genotype& genotype) const = 0;
};

} // namespace fatint::genetics
