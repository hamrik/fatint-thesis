#pragma once

#include "genetics/genetics.hpp"
#include "math/Random.hpp"
#include "model/types.hpp"

#include <memory>
#include <optional>

namespace fatint::genetics
{

/// A similarity metric based on euclidean distance.
class EuclideanDistanceSimilarity : public ISimilarity
{
  public:
    EuclideanDistanceSimilarity(model::ReproductionParameters params);
    ~EuclideanDistanceSimilarity() override = default;

    /// Checks whether two entities can reproduce.
    [[nodiscard]] auto compatible(const model::Entity &a, const model::Entity &b) const -> bool override;

    /// Checks how many offspring two entities can have.
    [[nodiscard]] auto offspring_count(const model::Entity &a, const model::Entity &b) const -> size_t override;

  private:
    model::ReproductionParameters params;
    size_t m_limit_sqr;

    [[nodiscard]] auto euclidean_distance_sqr(const model::Genotype &a, const model::Genotype &b) const -> size_t;
};

/// A selection algorithm based on reservoir sampling.
class ReservoirSelection : public ISelection
{
  public:
    ReservoirSelection(std::unique_ptr<ISimilarity> similarity);
    ~ReservoirSelection() override = default;

    /// Tries to select a compatible mate for the entity at the given index in the given population.
    /// Returns the index of a compatible mate or `nullopt` if so such mate can be found.
    auto select(math::Random &rng, const model::Population &entities, size_t subject_index) const
        -> std::optional<size_t> override;

  private:
    std::unique_ptr<ISimilarity> similarity;
};

/// A mutation algorithm selectively mutatates genes within a [-v, v] range.
class BoundedMutation : public IMutation
{
  public:
    BoundedMutation(double p_mutation, int v_mutation);
    ~BoundedMutation() override = default;

    /// Nudges the genes of the given genotype within [-v_mutation, v_mutation].
    void mutate(math::Random &rng, model::Genotype &genotype) const override;

  private:
    double p_mutation;
    int v_mutation;
};

/// A combination operator that randomly picks genes from the two parents with a bias.
class Crossover : public ICombination
{
  public:
    Crossover(double p_crossing);
    ~Crossover() override = default;

    /// Combines the genes of the first two given genotypes into the third.
    /// Requires uniformly sized genotypes, otherwise will throw an exception.
    void combine(math::Random &rng, const model::Genotype &a, const model::Genotype &b,
                 model::Genotype &out) const override;

  private:
    double p_crossing;
};

/// A reproduction algorithm that uses genetic operators.
class GeneticReproduction : public IReproduction
{
  public:
    GeneticReproduction(std::unique_ptr<IMutation> mutation, std::unique_ptr<ICombination> crossover, int v_min,
                        int v_max);
    ~GeneticReproduction() override = default;

    /// Combines the attributes (phenotype) of the first two entites into the third "offspring" entity.
    /// Returns whether the offspring entity is viable and can be added to the population.
    auto reproduce(math::Random &rng, const model::Entity &a, const model::Entity &b, model::Entity &out) const
        -> bool override;

  private:
    std::unique_ptr<IMutation> mutation;
    std::unique_ptr<ICombination> crossover;
    int v_min;
    int v_max;
};

/// A gene adder implementation that appends random genes.
class RandomGeneAdder : public IGeneAdder
{
  public:
    RandomGeneAdder(int v_min, int v_max);
    ~RandomGeneAdder() override = default;

    /// Adds one new gene to the given genotype.
    void add_gene(math::Random &random, model::Genotype &genotype) const override;

  private:
    int v_min;
    int v_max;
};

/// A deterministic gene adder implementation that uses the "Stretch formula"
/// described in the FATINT paper to determine the new gene from the last gene
/// of the given genotype.
class VStretchGeneAdder : public IGeneAdder
{
  public:
    VStretchGeneAdder(int v_min, int v_max, double v_stretch);
    ~VStretchGeneAdder() override = default;

    /// Adds one new gene to the given genotype.
    void add_gene(math::Random &random, model::Genotype &genotype) const override;

  private:
    int v_min;
    int v_max;
    double v_stretch;
};

} // namespace fatint::genetics
