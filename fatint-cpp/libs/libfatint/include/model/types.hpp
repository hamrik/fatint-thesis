/**
 * @file types.hpp
 * @brief Defines types and default values for all model parameters
 *
 * The model parameters have the following contraints defined in Table 2 of the
 * FATINT paper:
 *  - $-\infty < (V_{min} = 0) \leq (V_{max} = 100) < \infty$
 *  - $0 \leq V_{mutation} = 2 < \infty$
 *  - $0 \leq V_{stretch} = 1 < \infty$
 *  - $0 \leq M_{limit} = 15 < \infty$
 *  - $0 \leq M_{const} = 1 < \infty$
 *  - $0 \leq M_{slope} = 0 < \infty$
 *  - $0 \leq P_{encounter} = 0.1 \leq 1$
 *  - $0 \leq P_{crossing} = 0.2 \leq 1$
 *  - $0 \leq P_{mutation} = 0.1 \leq 1$
 *  - $0 \leq P_{change} = 0 \leq 1$
 *  - $0 \leq E_{increase} = 1000 < \infty$
 *  - $0 \leq E_{consumption} = 5 < \infty$
 *  - $0 \leq E_{intake} = 10 < \infty$
 *  - $0 \leq E_{discount} = 0.9 < \infty$
 */

#pragma once

#include <ostream>
#include <vector>

namespace fatint::model
{

const size_t DEFAULT_M_INIT{100};
const size_t DEFAULT_N_INIT{5};

const int DEFAULT_V_MIN{0};
const int DEFAULT_V_MAX{100};
const int DEFAULT_V_MUTATION{2};
const int DEFAULT_V_STRETCH{0};
const int DEFAULT_M_LIMIT{15};
const int DEFAULT_M_CONST{1};
const double DEFAULT_M_SLOPE{0};
const double DEFAULT_P_ENCOUNTER{0.1};
const double DEFAULT_P_CROSSING{0.2};
const double DEFAULT_P_MUTATION{0.1};
const double DEFAULT_P_CHANGE{0};
const double DEFAULT_E_INCREASE{1000};
const double DEFAULT_E_CONSUMPTION{5};
const double DEFAULT_E_INTAKE{10};
const double DEFAULT_E_DISCOUNT{0.9};

using Genotype = std::vector<int>;

struct Entity
{
    int age{};
    double energy{};
    Genotype genotype;
};

using Population = std::vector<Entity>;

struct Limits
{
    /// Minimum value of a gene.
    int v_min{DEFAULT_V_MIN};
    /// Maximum value of a gene.
    int v_max{DEFAULT_V_MAX};

    void validate();
};

struct ReproductionProbabilities
{
    /// Probability that an entity will attempt to reproduce each step.
    double p_encounter{DEFAULT_P_ENCOUNTER};
    /// Probability that a new gene will be added to every entity during
    /// reproduction. This simulates environment activated latent phenotypes.
    double p_change{DEFAULT_P_CHANGE};

    void validate();
};

struct ReproductionParameters
{
    /// Starting population size.
    size_t m_init{DEFAULT_M_INIT};
    /// Minimum number of offspring during reproduction.
    double m_const{DEFAULT_M_CONST};
    /// Slope of the offspring function.
    double m_slope{DEFAULT_M_SLOPE};
    /// Maximum number of offspring during reproduction.
    double m_limit{DEFAULT_M_LIMIT};

    void validate();
};

struct GeneticProbabilities
{
    /// Probability of gene crossover during reproduction.
    double p_crossing{DEFAULT_P_CROSSING};
    /// Probability that an gene will mutate during reproduction.
    double p_mutation{DEFAULT_P_MUTATION};

    void validate();
};

struct GeneticParameters
{
    /// Starting gene count.
    size_t n_init{DEFAULT_N_INIT};
    /// Maximum change of a gene during mutation.
    int v_mutation{DEFAULT_V_MUTATION};
    /// Stretch factor of a gene mutation.
    double v_stretch{DEFAULT_V_STRETCH};

    void validate();
};

struct EnergyParameters
{
    /// The amount of energy replenished by the environment after each step.
    double e_increase{DEFAULT_E_INCREASE};
    /// The amount of energy lost by an entity per step.
    double e_consumption{DEFAULT_E_CONSUMPTION};
    /// The maximum amount of energy consumed by a single entity per step.
    double e_intake{DEFAULT_E_INTAKE};
    /// Affects how much of the energy intake is wasted.
    double e_discount{DEFAULT_E_DISCOUNT};

    void validate();
};

} // namespace fatint::model

auto operator<<(std::ostream &os, const fatint::model::Limits &params) -> std::ostream &;
auto operator<<(std::ostream &os, const fatint::model::ReproductionProbabilities &params) -> std::ostream &;
auto operator<<(std::ostream &os, const fatint::model::ReproductionParameters &params) -> std::ostream &;
auto operator<<(std::ostream &os, const fatint::model::GeneticProbabilities &params) -> std::ostream &;
auto operator<<(std::ostream &os, const fatint::model::GeneticParameters &params) -> std::ostream &;
auto operator<<(std::ostream &os, const fatint::model::EnergyParameters &params) -> std::ostream &;
