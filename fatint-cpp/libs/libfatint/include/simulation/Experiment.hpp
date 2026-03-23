#pragma once

#include "genetics/genetics.hpp"
#include "measurement/types.hpp"
#include "simulation/types.hpp"

namespace fatint::simulation {

class Experiment
{
public:
  Experiment(ExperimentParameters parameters,
             genetics::ISimilarity& similarity,
             genetics::ISelection& selection,
             genetics::IReproduction& reproduction,
             genetics::IValidator& validator,
             genetics::IAlleleAdder& allele_adder,
             measurement::ISpeciesCounter& species_counter);

  ExperimentStates run();

private:
  ExperimentParameters parameters;
  genetics::ISimilarity& similarity;
  genetics::ISelection& selection;
  genetics::IReproduction& reproduction;
  genetics::IValidator& validator;
  genetics::IAlleleAdder& allele_adder;
  measurement::ISpeciesCounter& species_counter;
};

class ExperimentSweep
{
public:
  ExperimentSweep(ExperimentSweepParameters parameters,
                  genetics::ISimilarity& similarity,
                  genetics::ISelection& selection,
                  genetics::IReproduction& reproduction,
                  genetics::IValidator& validator,
                  genetics::IAlleleAdder& allele_adder,
                  measurement::ISpeciesCounter& species_counter);

  ExperimentSweepStates run();

private:
  ExperimentSweepParameters parameters;
  genetics::ISimilarity& similarity;
  genetics::ISelection& selection;
  genetics::IReproduction& reproduction;
  genetics::IValidator& validator;
  genetics::IAlleleAdder& allele_adder;
  measurement::ISpeciesCounter& species_counter;
};

} // namespace fatint::simulation
