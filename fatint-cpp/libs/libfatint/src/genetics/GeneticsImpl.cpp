#include "genetics/GeneticsImpl.hpp"

#include <cassert>

#include "genetics/genetics.hpp"
#include "measurement/ReservoirSampling.hpp"
#include "model/error.hpp"
#include "model/formulas.hpp"
#include "model/types.hpp"

namespace fatint::genetics
{

EuclideanDistanceSimilarity::EuclideanDistanceSimilarity(model::ReproductionParameters params)
    : params(params),
      m_limit_sqr(static_cast<size_t>(params.m_limit) * static_cast<size_t>(params.m_limit))
{
}

/// Checks whether two entities can reproduce.
auto EuclideanDistanceSimilarity::compatible(const model::Entity &a, const model::Entity &b) const -> bool
{
    if (a.genotype.size() != b.genotype.size())
    {
        throw fatint::error::MismatchException("EuclideanDistanceSimilarity requires uniform genotype sizes", a.genotype.size(), b.genotype.size());
    }
    return euclidean_distance_sqr(a.genotype, b.genotype) <= m_limit_sqr;
}

/// Checks how many offspring two entities can have.
auto EuclideanDistanceSimilarity::offspring_count(const model::Entity &a, const model::Entity &b) const -> size_t
{
    double eds = static_cast<double>(euclidean_distance_sqr(a.genotype, b.genotype));
    double dist = sqrt(eds);
    int oc = model::offspring_count(dist, params.m_const, params.m_limit, params.m_slope);
    return static_cast<size_t>(std::max(0, oc));
}

auto EuclideanDistanceSimilarity::euclidean_distance_sqr(const model::Genotype &a, const model::Genotype &b) const
    -> size_t
{
    size_t sum = 0;
    for (size_t i = 0; i < a.size(); i++)
    {
        int delta = a[i] - b[i];
        sum += static_cast<size_t>(delta * delta);
    }
    return sum;
}

ReservoirSelection::ReservoirSelection(std::unique_ptr<ISimilarity> similarity) : similarity(std::move(similarity))
{
}

auto ReservoirSelection::select(math::Random &rng, const model::Population &entities, size_t subject_index) const
    -> std::optional<size_t>
{
    measurement::ReservoirSampling<size_t> sampler;

    for (size_t i = 0; i < entities.size(); i++)
    {
        if (i == subject_index)
        {
            continue;
        }
        if (!similarity->compatible(entities[subject_index], entities[i]))
        {
            continue;
        }
        sampler.add(rng, i);
    }

    return sampler.get();
}

BoundedMutation::BoundedMutation(double p_mutation, int v_mutation) : p_mutation(p_mutation), v_mutation(v_mutation)
{
}

void BoundedMutation::mutate(math::Random &rng, model::Genotype &genotype) const
{
    for (auto &gene : genotype)
    {
        if (rng.chance(p_mutation))
        {
            gene += rng.random(-v_mutation, v_mutation);
        }
    }
}

Crossover::Crossover(double p_crossing) : p_crossing(p_crossing)
{
}

void Crossover::combine(math::Random &rng, const model::Genotype &a, const model::Genotype &b,
                        model::Genotype &out) const
{
    if (a.size() != b.size())
    {
        throw fatint::error::MismatchException("Crossover requires uniform parent genotype sizes", a.size(), b.size());
    }
    if (a.size() != out.size())
    {
        throw fatint::error::MismatchException("Crossover requires child genotype size to match parents", a.size(), out.size());
    }
    for (size_t i = 0; i < a.size(); i++)
    {
        if (rng.chance(p_crossing))
        {
            out[i] = b[i];
        }
        else
        {
            out[i] = a[i];
        }
    }
}

GeneticReproduction::GeneticReproduction(std::unique_ptr<IMutation> mutation, std::unique_ptr<ICombination> crossover,
                                         int v_min, int v_max)
    : mutation(std::move(mutation)), crossover(std::move(crossover)), v_min(v_min), v_max(v_max)
{
}

auto GeneticReproduction::reproduce(math::Random &rng, const model::Entity &a, const model::Entity &b,
                                    model::Entity &out) const -> bool
{
    out.age = 0;
    out.energy = 0;
    crossover->combine(rng, a.genotype, b.genotype, out.genotype);
    mutation->mutate(rng, out.genotype);
    for (auto &g : out.genotype)
    {
        if (g < v_min || g > v_max)
        {
            return false;
        }
    }
    return true;
}

RandomGeneAdder::RandomGeneAdder(int v_min, int v_max) : v_min(v_min), v_max(v_max)
{
}

void RandomGeneAdder::add_gene(math::Random &rng, model::Genotype &genotype) const
{
    genotype.push_back(rng.random(v_min, v_max));
}

VStretchGeneAdder::VStretchGeneAdder(int v_min, int v_max, double v_stretch)
    : v_min(v_min), v_max(v_max), v_stretch(v_stretch)
{
}

void VStretchGeneAdder::add_gene(math::Random &rng, model::Genotype &genotype) const
{
    genotype.push_back(model::stretch_gene(genotype.back(), v_min, v_max, v_stretch));
}

} // namespace fatint::genetics
