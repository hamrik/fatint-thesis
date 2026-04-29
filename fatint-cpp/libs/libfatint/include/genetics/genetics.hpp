#pragma once

#include "math/Random.hpp"
#include "model/types.hpp"

#include <optional>

namespace fatint::genetics
{

/// A common interface for any algorithm that can determine whether two entities may reproduce and how many offspring
/// they may have.
class ISimilarity
{
  public:
    virtual ~ISimilarity() = default;

    /// Checks whether two entities can reproduce.
    [[nodiscard]] virtual auto compatible(const model::Entity &a, const model::Entity &b) const -> bool = 0;
    /// Checks how many offspring two entities can have.
    [[nodiscard]] virtual auto offspring_count(const model::Entity &a, const model::Entity &b) const -> size_t = 0;
};

/// A common interface for any algorithm can select a compatible mate for a given entity.
class ISelection
{
  public:
    virtual ~ISelection() = default;

    /// Tries to select a compatible mate for the entity at the given index in the given population.
    /// Returns the index of a compatible mate or `nullopt` if so such mate can be found.
    virtual auto select(math::Random &rng, const model::Population &entities, size_t subject_index) const
        -> std::optional<size_t> = 0;
};

/// A common interface for any genetic algorithm that can mutate the given genotype.
class IMutation
{
  public:
    virtual ~IMutation() = default;

    /// Nudges the genes of the given genotype in a random direction.
    virtual void mutate(math::Random &rng, model::Genotype &genotype) const = 0;
};

/// A common interface for any algorithm that can combine two genotypes.
class ICombination
{
  public:
    virtual ~ICombination() = default;

    /// Combines the genes of the first two given genotypes into the third.
    /// It is up to the implementation to decide how to handle non-uniform sizes.
    virtual void combine(math::Random &rng, const model::Genotype &a, const model::Genotype &b,
                         model::Genotype &out) const = 0;
};

/// A common interface for any algorithm that can combine two entities into a third offspring entity.
class IReproduction
{
  public:
    virtual ~IReproduction() = default;

    /// Combines the attributes (phenotype) of the first two entites into the third "offspring" entity.
    /// Returns whether the offspring entity is viable and can be added to the population.
    virtual auto reproduce(math::Random &rng, const model::Entity &a, const model::Entity &b, model::Entity &out) const
        -> bool = 0;
};

/// A common interface for any algorithm that can extend the given genotype with a new gene.
class IGeneAdder
{
  public:
    virtual ~IGeneAdder() = default;

    /// Adds one new gene to the given genotype.
    virtual void add_gene(math::Random &random, model::Genotype &genotype) const = 0;
};

} // namespace fatint::genetics
