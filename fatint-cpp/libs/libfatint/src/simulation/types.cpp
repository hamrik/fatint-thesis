#include "simulation/types.hpp"
#include "model/error.hpp"

void fatint::simulation::RunParameters::validate()
{
    if(steps < 1) {
        throw fatint::error::ConstraintException("constraint violated: 1 <= steps");
    }
    limits.validate();
    reproduction_probabilities.validate();
    reproduction_parameters.validate();
    genetic_probabilities.validate();
    genetic_parameters.validate();
    energy_parameters.validate();
}

void fatint::simulation::ExperimentParameters::validate()
{
    if(runs < 1) {
        throw fatint::error::ConstraintException("constraint violated: 1 <= runs");
    }
    run_parameters.validate();
}

void fatint::simulation::ExperimentSweepParameters::validate()
{
    if(experiments < 1) {
        throw fatint::error::ConstraintException("constraint violated: 1 <= experiments");
    }
    starting_parameters.validate();
    ExperimentParameters p{starting_parameters};
    for(size_t i = 0; i < experiments; i++) {
        p.validate();
        p.run_parameters += delta;
    }
}

auto operator<<(std::ostream &os, const fatint::simulation::RunParameters &params) -> std::ostream &
{
    os << params.limits << params.reproduction_probabilities << params.reproduction_parameters
       << params.genetic_probabilities << params.genetic_parameters << params.energy_parameters;
    return os;
}
