#include "model/types.hpp"
#include <ostream>

namespace fatint::model {

Limits::Limits()
  : v_min(DEFAULT_V_MIN)
  , v_max(DEFAULT_V_MAX)
  , m_limit(DEFAULT_M_LIMIT)
{
}

ReproductionProbabilities::ReproductionProbabilities()
  : p_encounter(DEFAULT_P_ENCOUNTER)
  , p_change(DEFAULT_P_CHANGE)
{
}

ReproductionParameters::ReproductionParameters()
  : starting_population(DEFAULT_STARTING_POPULATION_SIZE)
  , m_const(DEFAULT_M_CONST)
  , m_slope(DEFAULT_M_SLOPE)
{
}

GeneticProbabilities::GeneticProbabilities()
  : p_crossing(DEFAULT_P_CROSSING)
  , p_mutation(DEFAULT_P_MUTATION)
{
}

AlleleParameters::AlleleParameters()
  : starting_allele_count(DEFAULT_STARTING_ALLELE_COUNT)
  , v_mutation(DEFAULT_V_MUTATION)
  , v_stretch(DEFAULT_V_STRETCH)
{
}

EnergyParameters::EnergyParameters()
  : e_increase(DEFAULT_E_INCREASE)
  , e_consumption(DEFAULT_E_CONSUMPTION)
  , e_intake(DEFAULT_E_INTAKE)
  , e_discount(DEFAULT_E_DISCOUNT)
{
}

} // namespace fatint::model

auto
operator<<(std::ostream& os, const fatint::model::Limits& params)
  -> std::ostream&
{
  if (params.m_limit != fatint::model::DEFAULT_M_LIMIT)
    os << " M_limit=" << params.m_limit;
  if (params.v_min != fatint::model::DEFAULT_V_MIN)
    os << " V_min=" << params.v_min;
  if (params.v_max != fatint::model::DEFAULT_V_MAX)
    os << " V_max=" << params.v_max;
  return os;
}

auto
operator<<(std::ostream& os,
           const fatint::model::ReproductionProbabilities& params)
  -> std::ostream&
{
  if (params.p_encounter != fatint::model::DEFAULT_P_ENCOUNTER)
    os << " P_encounter=" << params.p_encounter;
  if (params.p_change != fatint::model::DEFAULT_P_CHANGE)
    os << " P_change=" << params.p_change;
  return os;
}

auto
operator<<(std::ostream& os,
           const fatint::model::ReproductionParameters& params) -> std::ostream&
{
  if (params.starting_population !=
      fatint::model::DEFAULT_STARTING_POPULATION_SIZE)
    os << " StartingPopulation=" << params.starting_population;
  if (params.m_const != fatint::model::DEFAULT_M_CONST)
    os << " M_const=" << params.m_const;
  if (params.m_slope != fatint::model::DEFAULT_M_SLOPE)
    os << " M_slope=" << params.m_slope;
  return os;
}

auto
operator<<(std::ostream& os, const fatint::model::GeneticProbabilities& params)
  -> std::ostream&
{
  if (params.p_crossing != fatint::model::DEFAULT_P_CROSSING)
    os << " P_crossing=" << params.p_crossing;
  if (params.p_mutation != fatint::model::DEFAULT_P_MUTATION)
    os << " P_mutation=" << params.p_mutation;
  return os;
}

auto
operator<<(std::ostream& os, const fatint::model::AlleleParameters& params)
  -> std::ostream&
{
  if (params.starting_allele_count !=
      fatint::model::DEFAULT_STARTING_ALLELE_COUNT)
    os << " StartingAlleleCount=" << params.starting_allele_count;
  if (params.v_mutation != fatint::model::DEFAULT_V_MUTATION)
    os << " V_mutation=" << params.v_mutation;
  if (params.v_stretch != fatint::model::DEFAULT_V_STRETCH)
    os << " V_stretch=" << params.v_stretch;
  return os;
}

auto
operator<<(std::ostream& os, const fatint::model::EnergyParameters& params)
  -> std::ostream&
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
