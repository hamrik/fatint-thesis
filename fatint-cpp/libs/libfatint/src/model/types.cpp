#include "model/types.hpp"
#include "model/error.hpp"

#include <ostream>

namespace fatint::model
{

void Limits::validate()
{
    if (v_min > v_max)
    {
        throw fatint::error::ParameterConstraintException("contraint violated: v_min <= v_max", v_max);
    }
}

void ReproductionProbabilities::validate()
{
    if (p_encounter < 0 || p_encounter > 1.0)
    {
        throw fatint::error::ParameterConstraintException("constraint violated: 0 <= p_encounter <= 1", p_encounter);
    }
    if (p_change < 0 || p_change > 1.0)
    {
        throw fatint::error::ParameterConstraintException("constraint violated: 0 <= p_change <= 1", p_change);
    }
}

void ReproductionParameters::validate()
{
    if (m_init < 1)
    {
        throw fatint::error::ParameterConstraintException("constraint violated: 1 <= m_init", m_init);
    }
    if (m_const < 0)
    {
        throw fatint::error::ParameterConstraintException("constraint violated: 0 <= m_const", m_const);
    }
}

void GeneticProbabilities::validate()
{
    if (p_crossing < 0 || p_crossing > 1.0)
    {
        throw fatint::error::ParameterConstraintException("constraint violated: 0 <= p_crossing <= 1", p_crossing);
    }
    if (p_mutation < 0 || p_mutation > 1.0)
    {
        throw fatint::error::ParameterConstraintException("constraint violated: 0 <= p_mutation <= 1", p_mutation);
    }
}

void GeneticParameters::validate()
{
    if (n_init < 1)
    {
        throw fatint::error::ParameterConstraintException("constraint violated: 1 <= n_init", n_init);
    }
}

void EnergyParameters::validate()
{
    if (e_increase < 0)
    {
        throw fatint::error::ParameterConstraintException("constraint violated: 0 <= e_increase", e_increase);
    }
    if (e_consumption < 0)
    {
        throw fatint::error::ParameterConstraintException("constraint violated: 0 <= e_consumption", e_consumption);
    }
    if (e_intake < 0)
    {
        throw fatint::error::ParameterConstraintException("constraint violated: 0 <= e_intake", e_intake);
    }
    if (e_discount < 0 || e_discount > 1.0)
    {
        throw fatint::error::ParameterConstraintException("constraint violated: 0 <= e_discount <= 1", e_discount);
    }
}

} // namespace fatint::model

auto operator<<(std::ostream &os, const fatint::model::Limits &params) -> std::ostream &
{
    if (params.v_min != fatint::model::DEFAULT_V_MIN)
        os << " V_min=" << params.v_min;
    if (params.v_max != fatint::model::DEFAULT_V_MAX)
        os << " V_max=" << params.v_max;
    return os;
}

auto operator<<(std::ostream &os, const fatint::model::ReproductionProbabilities &params) -> std::ostream &
{
    if (params.p_encounter != fatint::model::DEFAULT_P_ENCOUNTER)
        os << " P_encounter=" << params.p_encounter;
    if (params.p_change != fatint::model::DEFAULT_P_CHANGE)
        os << " P_change=" << params.p_change;
    return os;
}

auto operator<<(std::ostream &os, const fatint::model::ReproductionParameters &params) -> std::ostream &
{
    if (params.m_init != fatint::model::DEFAULT_M_INIT)
        os << " StartingPopulation=" << params.m_init;
    if (params.m_const != fatint::model::DEFAULT_M_CONST)
        os << " M_const=" << params.m_const;
    if (params.m_slope != fatint::model::DEFAULT_M_SLOPE)
        os << " M_slope=" << params.m_slope;
    if (params.m_limit != fatint::model::DEFAULT_M_LIMIT)
        os << " M_limit=" << params.m_limit;
    return os;
}

auto operator<<(std::ostream &os, const fatint::model::GeneticProbabilities &params) -> std::ostream &
{
    if (params.p_crossing != fatint::model::DEFAULT_P_CROSSING)
        os << " P_crossing=" << params.p_crossing;
    if (params.p_mutation != fatint::model::DEFAULT_P_MUTATION)
        os << " P_mutation=" << params.p_mutation;
    return os;
}

auto operator<<(std::ostream &os, const fatint::model::GeneticParameters &params) -> std::ostream &
{
    if (params.n_init != fatint::model::DEFAULT_N_INIT)
        os << " N_init=" << params.n_init;
    if (params.v_mutation != fatint::model::DEFAULT_V_MUTATION)
        os << " V_mutation=" << params.v_mutation;
    if (params.v_stretch != fatint::model::DEFAULT_V_STRETCH)
        os << " V_stretch=" << params.v_stretch;
    return os;
}

auto operator<<(std::ostream &os, const fatint::model::EnergyParameters &params) -> std::ostream &
{
    if (params.e_increase != fatint::model::DEFAULT_E_INCREASE)
        os << " E_increase=" << params.e_increase;
    if (params.e_consumption != fatint::model::DEFAULT_E_CONSUMPTION)
        os << " E_consumption=" << params.e_consumption;
    if (params.e_intake != fatint::model::DEFAULT_E_INTAKE)
        os << " E_intake=" << params.e_intake;
    if (params.e_discount != fatint::model::DEFAULT_E_DISCOUNT)
        os << " E_discount=" << params.e_discount;
    return os;
}
