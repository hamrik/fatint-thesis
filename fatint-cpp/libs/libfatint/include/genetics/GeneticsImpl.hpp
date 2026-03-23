#pragma once

#include "genetics/genetics.hpp"
#include "math/Random.hpp"

#include <optional>

namespace fatint::genetics {

class SimilarityImpl : public ISimilarity
{
public:
  SimilarityImpl(const model::Limits& limits);
  bool compatible(const model::Genotype& a,
                  const model::Genotype& b) const override;

private:
  const model::Limits limits;
};

class SelectionImpl : public ISelection
{
public:
  std::optional<size_t> select(math::Random& random,
                               const ISimilarity& similarity,
                               size_t index,
                               const model::Population& entities) override;
};

class MutationImpl : public IMutation
{
public:
  void mutate(math::Random& random,
              double p_mutation,
              int v_mutation,
              model::Genotype& genotype) override;
};

class CrossoverImpl : public ICrossover
{
public:
  void crossover(math::Random& random,
                 double p_crossing,
                 const model::Genotype& a,
                 const model::Genotype& b,
                 model::Genotype& out) override;
};

class ValidatorImpl : public IValidator
{
public:
  bool validate(const model::Limits& limits,
                const model::Genotype& genotype) const override;
};

class RandomAlleleAdder : public IAlleleAdder
{
public:
  void add_allele(math::Random& random,
                  const model::Limits& limits,
                  const model::AlleleParameters& parameters,
                  model::Genotype& genotype) override;
};

class VStretchAlleleAdder : public IAlleleAdder
{
public:
  void add_allele(math::Random& random,
                  const model::Limits& limits,
                  const model::AlleleParameters& parameters,
                  model::Genotype& genotype) override;
};

} // namespace fatint::genetics
