/**
 * @file formulas.hpp
 * @brief Defines the core formulas of the model used in the simulation
 */
#pragma once

#include <cassert>
#include <cmath>

namespace fatint::model
{

/// Determines how much energy a given entity gains from the energy it took
inline auto entity_energy_change(int age, double energy_taken, double e_discount, double e_consumption) -> double
{
    double energy_gained = energy_taken * pow(e_discount, static_cast<double>(age));
    return energy_gained - e_consumption;
}

/// Determines how many entities a pair of compatible entities can create
inline auto offspring_count(double genetic_distance, size_t m_const, size_t m_limit, double m_slope) -> int
{
    assert(genetic_distance >= 0);
    assert(m_const >= 0);
    assert(m_limit >= genetic_distance);
    assert(m_slope >= 0);
    return static_cast<int>(floor(static_cast<double>(m_const) - (static_cast<double>(m_limit) - genetic_distance) * m_slope));
}

/// Determines the next gene to be added to the entity given its current
/// genotype
inline auto stretch_gene(int last_gene, int v_min, int v_max, double v_stretch) -> int
{
    int offset = static_cast<int>(floor(last_gene * v_stretch));
    int wrapped = offset % (v_max - v_min + 1);
    return v_min + wrapped;
}

} // namespace fatint::model
