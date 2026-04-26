#include "genetics/GeneticsImpl.hpp"

#include <cassert>

#include "measurement/ReservoirSampling.hpp"
#include "model/formulas.hpp"
#include "model/types.hpp"

namespace fatint::genetics
{

auto SimilarityImpl::compatible(const model::Limits &limits, const model::Genotype &a, const model::Genotype &b) const
    -> bool
{
    assert(a.size() == b.size());
    auto limit_sqr = static_cast<size_t>(limits.m_limit * limits.m_limit);
    return euclidean_distance_sqr(a, b) <= limit_sqr;
}
auto SimilarityImpl::offspring_count(const model::Limits &limits, const model::ReproductionParameters &repr,
                                     const model::Genotype &a, const model::Genotype &b) const -> size_t
{
    double eds = static_cast<double>(euclidean_distance_sqr(a, b));
    double dist = sqrt(eds);
    int oc = model::offspring_count(dist, repr.m_const, limits.m_limit, repr.m_slope);
    return static_cast<size_t>(std::max(0, oc));
}
auto SimilarityImpl::euclidean_distance_sqr(const model::Genotype &a, const model::Genotype &b) const -> size_t
{
    size_t sum = 0;
    for (size_t i = 0; i < a.size(); i++)
    {
        int delta = a[i] - b[i];
        sum += static_cast<size_t>(delta * delta);
    }
    return sum;
}

auto SelectionImpl::select(math::Random &random, const model::Limits &limits, const ISimilarity &similarity,
                           size_t index, const model::Population &entities) const -> std::optional<size_t>
{
    measurement::ReservoirSampling<size_t> sampler;

    for (size_t i = 0; i < entities.size(); i++)
    {
        if (i == index)
        {
            continue;
        }
        if (!similarity.compatible(limits, entities[index].genotype, entities[i].genotype))
        {
            continue;
        }
        sampler.add(random, i);
    }

    return sampler.get();
}

void MutationImpl::mutate(math::Random &random, double p_mutation, int v_mutation, model::Genotype &genotype) const
{
    for (auto &gene : genotype)
    {
        if (random.chance(p_mutation))
        {
            gene += random.random(-v_mutation, v_mutation);
        }
    }
}

void CrossoverImpl::crossover(math::Random &random, double p_crossing, const model::Genotype &a,
                              const model::Genotype &b, model::Genotype &out) const
{
    assert(a.size() == b.size());
    assert(out.size() == a.size());
    for (size_t i = 0; i < a.size(); i++)
    {
        if (random.chance(p_crossing))
        {
            out[i] = b[i];
        }
        else
        {
            out[i] = a[i];
        }
    }
}

auto ValidatorImpl::validate(const model::Limits &limits, const model::Genotype &genotype) const -> bool
{
    for (auto gene : genotype)
    {
        if (gene < limits.v_min || gene > limits.v_max)
        {
            return false;
        }
    }
    return true;
}

void RandomAlleleAdder::add_allele(math::Random &random, const model::Limits &limits,
                                   const model::AlleleParameters &parameters, model::Genotype &genotype) const
{
    genotype.push_back(random.random(limits.v_min, limits.v_max));
}

void VStretchAlleleAdder::add_allele(math::Random &random, const model::Limits &limits,
                                     const model::AlleleParameters &parameters, model::Genotype &genotype) const
{
    genotype.push_back(model::stretch_allele(genotype.back(), limits.v_min, limits.v_max, parameters.v_stretch));
}

} // namespace fatint::genetics
