#include "model/utils.hpp"

namespace fatint::model
{

auto operator+=(Limits &a, const Limits &b) -> Limits &
{
    a.v_min += b.v_min;
    a.v_max += b.v_max;
    return a;
}

auto operator+=(ReproductionProbabilities &a, const ReproductionProbabilities &b) -> ReproductionProbabilities &
{
    a.p_encounter += b.p_encounter;
    a.p_change += b.p_change;
    return a;
}

auto operator+=(ReproductionParameters &a, const ReproductionParameters &b) -> ReproductionParameters &
{
    a.m_init += b.m_init;
    a.m_const += b.m_const;
    a.m_slope += b.m_slope;
    a.m_limit += b.m_limit;
    return a;
}

auto operator+=(GeneticProbabilities &a, const GeneticProbabilities &b) -> GeneticProbabilities &
{
    a.p_crossing += b.p_crossing;
    a.p_mutation += b.p_mutation;
    return a;
}

auto operator+=(GeneticParameters &a, const GeneticParameters &b) -> GeneticParameters &
{
    a.n_init += b.n_init;
    a.v_mutation += b.v_mutation;
    a.v_stretch += b.v_stretch;
    return a;
}

auto operator+=(EnergyParameters &a, const EnergyParameters &b) -> EnergyParameters &
{
    a.e_increase += b.e_increase;
    a.e_consumption += b.e_consumption;
    a.e_intake += b.e_intake;
    a.e_discount += b.e_discount;
    return a;
}

} // namespace fatint::model
