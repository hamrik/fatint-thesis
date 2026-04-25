#include "simulation/types.hpp"

auto operator<<(std::ostream &os, const fatint::simulation::RunParameters &params) -> std::ostream &
{
    os << params.limits << params.reproduction_probabilities << params.reproduction_parameters
       << params.genetic_probabilities << params.allele_parameters << params.energy_parameters;
    return os;
}
