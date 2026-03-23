#include "io/CSVWriter.hpp"

#include "simulation/types.hpp"
#include "simulation/utils.hpp"

namespace fatint::io {

void
CSVWriter::write_header(const simulation::ExperimentParameters& params,
                        std::ostream& dest)
{
  dest << "starting_population,starting_allele_count,"
          "p_encounter,p_change,p_crossing,p_mutation,"
          "v_min,v_max,v_mutation,v_stretch,"
          "m_const,m_limit,m_slope,"
          "e_increase,e_consumption,e_intake,e_discount,step,"
          "minimum_entity_count,average_entity_count,maximum_entity_count,"
          "entity_count_sd,entity_count_error,"
          "minimum_allele_count,average_allele_count,maximum_allele_count,"
          "allele_count_sd,allele_count_error,"
          "minimum_species_count,average_species_count,maximum_species_count,"
          "species_count_sd,species_count_error";
  for (size_t i = 0; i < params.runs; i++) {
    dest << ",run_" << i << "_entity_count";
    dest << ",run_" << i << "_allele_count";
    dest << ",run_" << i << "_species_count";
  }
}

void
CSVWriter::write_row(size_t step,
                     const simulation::ExperimentParameters& params,
                     const simulation::Statistics& result,
                     std::ostream& dest)
{
  dest << "\n";
  dest << params.run_parameters.reproduction_parameters.starting_population
       << ",";
  dest << params.run_parameters.allele_parameters.starting_allele_count << ",";
  dest << params.run_parameters.reproduction_probabilities.p_encounter << ",";
  dest << params.run_parameters.reproduction_probabilities.p_change << ",";
  dest << params.run_parameters.genetic_probabilities.p_crossing << ",";
  dest << params.run_parameters.genetic_probabilities.p_mutation << ",";
  dest << params.run_parameters.limits.v_min << ",";
  dest << params.run_parameters.limits.v_max << ",";
  dest << params.run_parameters.allele_parameters.v_mutation << ",";
  dest << params.run_parameters.allele_parameters.v_stretch << ",";
  dest << params.run_parameters.limits.m_limit << ",";
  dest << params.run_parameters.reproduction_parameters.m_const << ",";
  dest << params.run_parameters.reproduction_parameters.m_slope << ",";
  dest << params.run_parameters.energy_parameters.e_increase << ",";
  dest << params.run_parameters.energy_parameters.e_consumption << ",";
  dest << params.run_parameters.energy_parameters.e_intake << ",";
  dest << params.run_parameters.energy_parameters.e_discount << ",";
  dest << step << ",";
  dest << result.entity_count.min << ",";
  dest << result.entity_count.avg << ",";
  dest << result.entity_count.max << ",";
  dest << result.entity_count.std << ",";
  dest << result.entity_count.err << ",";
  dest << result.allele_count.min << ",";
  dest << result.allele_count.avg << ",";
  dest << result.allele_count.max << ",";
  dest << result.allele_count.std << ",";
  dest << result.allele_count.err << ",";
  dest << result.species_count.min << ",";
  dest << result.species_count.avg << ",";
  dest << result.species_count.max << ",";
  dest << result.species_count.std << ",";
  dest << result.species_count.err;
  for (size_t j = 0; j < params.runs; j++) {
    dest << "," << result.entity_count_values[j];
    dest << "," << result.allele_count_values[j];
    dest << "," << result.species_count_values[j];
  }
}

void
CSVWriter::write(const simulation::ExperimentParameters& params,
                 const simulation::ExperimentResults& results,
                 std::ostream& dest)
{
  write_header(params, dest);
  for (size_t i = 0; i < params.run_parameters.steps; i++) {
    write_row(i, params, results[i], dest);
  }
}

void
CSVWriter::write(const simulation::ExperimentSweepParameters& params,
                 const simulation::ExperimentSweepResults& results,
                 std::ostream& dest)
{
  write_header(params.starting_parameters, dest);
  simulation::ExperimentParameters exp_params = params.starting_parameters;
  for (size_t e = 0; e < params.experiments; e++) {
    for (size_t r = 0; r < params.starting_parameters.run_parameters.steps;
         r++) {
      write_row(r, exp_params, results[e][r], dest);
    }
    exp_params.run_parameters += params.delta;
  }
}

} // namespace fatint::io
