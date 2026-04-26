#pragma once

#include "genetics/genetics.hpp"
#include "math/Random.hpp"

#include <optional>

namespace fatint::genetics
{

class SimilarityImpl : public ISimilarity
{
  public:
    [[nodiscard]] auto compatible(const model::Limits &limits, const model::Genotype &a, const model::Genotype &b) const
        -> bool override;
    [[nodiscard]] auto offspring_count(const model::Limits &limits, const model::ReproductionParameters &repr,
                                       const model::Genotype &a, const model::Genotype &b) const -> size_t override;

  private:
    [[nodiscard]] auto euclidean_distance_sqr(const model::Genotype &a, const model::Genotype &b) const -> size_t;
};

class SelectionImpl : public ISelection
{
  public:
    [[nodiscard]] auto select(math::Random &random, const model::Limits &limits, const ISimilarity &similarity,
                              size_t index, const model::Population &entities) const -> std::optional<size_t> override;
};

class MutationImpl : public IMutation
{
  public:
    void mutate(math::Random &random, double p_mutation, int v_mutation, model::Genotype &genotype) const override;
};

class CrossoverImpl : public ICrossover
{
  public:
    void crossover(math::Random &random, double p_crossing, const model::Genotype &a, const model::Genotype &b,
                   model::Genotype &out) const override;
};

class ValidatorImpl : public IValidator
{
  public:
    [[nodiscard]] auto validate(const model::Limits &limits, const model::Genotype &genotype) const -> bool override;
};

class RandomAlleleAdder : public IAlleleAdder
{
  public:
    void add_allele(math::Random &random, const model::Limits &limits, const model::AlleleParameters &parameters,
                    model::Genotype &genotype) const override;
};

class VStretchAlleleAdder : public IAlleleAdder
{
  public:
    void add_allele(math::Random &random, const model::Limits &limits, const model::AlleleParameters &parameters,
                    model::Genotype &genotype) const override;
};

} // namespace fatint::genetics
