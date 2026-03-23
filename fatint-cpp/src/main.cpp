#include "genetics/GeneticReproduction.hpp"
#include "genetics/GeneticsImpl.hpp"
#include "io/CSVWriter.hpp"
#include "io/SVGWriter.hpp"
#include "math/Statistics.hpp"
#include "measurement/DisjointSetsSpeciesCounter.hpp"
#include "simulation/Experiment.hpp"

#include "simulation/types.hpp"

#include <fstream>
#include <iostream>
#include <ostream>

#include <cxxopts.hpp>

template<typename T>
auto
def(std::string value)
{
  return cxxopts::value<T>()->default_value(value);
}

cxxopts::ParseResult
define_args(cxxopts::Options& options, int argc, char** argv)
{
  auto opt = options.add_options();

  // Define hyperparameters
  opt("e,experiments", "Number of experiments", def<unsigned int>("1"));
  opt("r,runs", "Number of runs per experiment", def<unsigned int>("10"));
  opt("s,steps", "Number of iterations", def<unsigned int>("6000"));
  opt("S,seed", "Random seed", def<unsigned int>("1"));

  // Define run parameters
  opt("p,starting_population",
      "Initial population size",
      def<unsigned int>("100"));
  opt("g,starting_allele_count",
      "Initial number of alleles",
      def<unsigned int>("5"));

  opt("p_encounter", "Probability of reproduction attempt", def<double>("0.1"));
  opt("p_change",
      "Probability of new gene per successful reproduction",
      def<double>("0.0"));
  opt("p_crossing", "Probability of crossover per gene", def<double>("0.2"));
  opt("p_mutation", "Probability of mutation per gene", def<double>("0.1"));

  opt("v_min", "Minimum allele", def<int>("0"));
  opt("v_max", "Maximum allele", def<int>("100"));
  opt("v_mutation", "Maximum allele mutation", def<double>("2"));
  opt("v_stretch",
      "Stretch factor when introducing new gene\n(0 = generate "
      "random gene)",
      def<double>("0.0"));

  opt("m_const",
      "Minimum number of offsprings per reproduction",
      def<double>("1"));
  opt("m_limit",
      "Maximum number of offsprings per reproduction",
      def<double>("15"));
  opt("m_slope",
      "How much should similarity affect offspring count",
      def<double>("0.0"));

  opt("e_increase",
      "Amount of energy the environment replenishes after "
      "each iteration",
      def<double>("1000.0"));
  opt("e_consumption", "Energy consumption per iteration", def<double>("5.0"));
  opt("e_intake", "Energy intake per iteration", def<double>("10.0"));
  opt("e_discount", "Energy discount per age", def<double>("0.9"));

  // Define run parameter deltas
  opt("dp,sweep_starting_population",
      "Initial population size delta",
      def<unsigned int>("0"));
  opt("dg,sweep_starting_allele_count",
      "Initial number of alleles delta",
      def<unsigned int>("0"));

  opt("sweep_p_encounter",
      "The amount p_encounter is increased by between experiments",
      def<double>("0"));
  opt("sweep_p_change",
      "The amount p_change is increased by between experiments",
      def<double>("0"));
  opt("sweep_p_crossing",
      "The amount p_crossing is increased by between experiments",
      def<double>("0"));
  opt("sweep_p_mutation",
      "The amount p_mutation is increased by between experiments",
      def<double>("0"));

  opt("sweep_v_min",
      "The amount v_min is increased by between experiments",
      def<int>("0"));
  opt("sweep_v_max",
      "The amount v_max is increased by between experiments",
      def<int>("0"));
  opt("sweep_v_mutation",
      "The amount v_mutation is increased by between experiments",
      def<double>("0"));
  opt("sweep_v_stretch",
      "The amount v_stretch is increased by between experiments",
      def<double>("0.0"));

  opt("sweep_m_const",
      "The amount m_const is increased by between experiments",
      def<double>("0"));
  opt("sweep_m_limit",
      "The amount m_limit is increased by between experiments",
      def<double>("0"));
  opt("sweep_m_slope",
      "The amount m_slope is increased by between experiments",
      def<double>("0.0"));

  opt("sweep_e_increase",
      "The amount e_increase is increased by between experiments",
      def<double>("0"));
  opt("sweep_e_consumption",
      "The amount e_consumption is increased by between experiments",
      def<double>("0"));
  opt("sweep_e_intake",
      "The amount e_intake is increased by between experiments",
      def<double>("0"));
  opt("sweep_e_discount",
      "The amount e_discount is increased by between experiments",
      def<double>("0"));

  opt("o,output", "Output file", def<std::string>(""));
  opt("f,format", "Output format", def<std::string>("csv"));

  // Help
  opt("h,help", "Print help");

  return options.parse(argc, argv);
}

fatint::simulation::ExperimentSweepParameters
parse_args(cxxopts::ParseResult& result)
{
  try {
    fatint::simulation::ExperimentSweepParameters experiment_sweep_parameters;
    fatint::simulation::ExperimentParameters experiment_parameters;
    fatint::simulation::RunParameters initial_run_parameters = { 0 };
    fatint::simulation::RunParameters delta = { 0 };
    int experiment_count = result["experiments"].as<unsigned int>();

    initial_run_parameters.steps = result["steps"].as<unsigned int>();
    initial_run_parameters.seed = result["seed"].as<unsigned int>();
    initial_run_parameters.reproduction_parameters.starting_population =
      result["starting_population"].as<unsigned int>();
    initial_run_parameters.allele_parameters.starting_allele_count =
      result["starting_allele_count"].as<unsigned int>();

    initial_run_parameters.reproduction_probabilities.p_encounter =
      result["p_encounter"].as<double>();
    initial_run_parameters.reproduction_probabilities.p_change =
      result["p_change"].as<double>();
    initial_run_parameters.genetic_probabilities.p_crossing =
      result["p_crossing"].as<double>();
    initial_run_parameters.genetic_probabilities.p_mutation =
      result["p_mutation"].as<double>();

    initial_run_parameters.limits.v_min = result["v_min"].as<int>();
    initial_run_parameters.limits.v_max = result["v_max"].as<int>();
    initial_run_parameters.allele_parameters.v_mutation =
      result["v_mutation"].as<double>();
    initial_run_parameters.allele_parameters.v_stretch =
      result["v_stretch"].as<double>();

    initial_run_parameters.reproduction_parameters.m_const =
      result["m_const"].as<double>();
    initial_run_parameters.limits.m_limit = result["m_limit"].as<double>();
    initial_run_parameters.reproduction_parameters.m_slope =
      result["m_slope"].as<double>();

    initial_run_parameters.energy_parameters.e_increase =
      result["e_increase"].as<double>();
    initial_run_parameters.energy_parameters.e_consumption =
      result["e_consumption"].as<double>();
    initial_run_parameters.energy_parameters.e_intake =
      result["e_intake"].as<double>();
    initial_run_parameters.energy_parameters.e_discount =
      result["e_discount"].as<double>();

    delta.reproduction_parameters.starting_population =
      result["sweep_starting_population"].as<unsigned int>();
    delta.allele_parameters.starting_allele_count =
      result["sweep_starting_allele_count"].as<unsigned int>();

    delta.reproduction_probabilities.p_encounter =
      result["sweep_p_encounter"].as<double>();
    delta.reproduction_probabilities.p_change =
      result["sweep_p_change"].as<double>();
    delta.genetic_probabilities.p_crossing =
      result["sweep_p_crossing"].as<double>();
    delta.genetic_probabilities.p_mutation =
      result["sweep_p_mutation"].as<double>();

    delta.limits.v_min = result["sweep_v_min"].as<int>();
    delta.limits.v_max = result["sweep_v_max"].as<int>();
    delta.allele_parameters.v_mutation =
      result["sweep_v_mutation"].as<double>();
    delta.allele_parameters.v_stretch = result["sweep_v_stretch"].as<double>();

    delta.reproduction_parameters.m_const =
      result["sweep_m_const"].as<double>();
    delta.limits.m_limit = result["sweep_m_limit"].as<double>();
    delta.reproduction_parameters.m_slope =
      result["sweep_m_slope"].as<double>();

    delta.energy_parameters.e_increase =
      result["sweep_e_increase"].as<double>();
    delta.energy_parameters.e_consumption =
      result["sweep_e_consumption"].as<double>();
    delta.energy_parameters.e_intake = result["sweep_e_intake"].as<double>();
    delta.energy_parameters.e_discount =
      result["sweep_e_discount"].as<double>();

    experiment_parameters.run_parameters = initial_run_parameters;
    experiment_parameters.runs = result["runs"].as<unsigned int>();

    experiment_sweep_parameters.starting_parameters = experiment_parameters;
    experiment_sweep_parameters.delta = delta;
    experiment_sweep_parameters.experiments = experiment_count;

    return experiment_sweep_parameters;
  } catch (const cxxopts::exceptions::exception& e) {
    std::cerr << "Error parsing options: " << e.what() << std::endl;
    exit(1);
  }
}

int
main(int argc, char** argv)
{
  cxxopts::Options options(argv[0], "FATINT simulation");

  cxxopts::ParseResult opts;
  try {
    opts = define_args(options, argc, argv);
    if (opts.count("help")) {
      std::cerr << options.help() << std::endl;
      exit(0);
    }
  } catch (const cxxopts::exceptions::exception& e) {
    std::cerr << "Error parsing arguments: " << e.what() << std::endl;
    std::cerr << options.help() << std::endl;
    exit(1);
  }

  std::string output_file = opts["output"].as<std::string>();
  std::string format = opts["format"].as<std::string>();

  fatint::simulation::ExperimentSweepParameters experiment_sweep_parameters =
    parse_args(opts);

  fatint::genetics::SimilarityImpl similarity(
    experiment_sweep_parameters.starting_parameters.run_parameters.limits);
  fatint::genetics::SelectionImpl selection;
  fatint::genetics::MutationImpl mutation;
  fatint::genetics::CrossoverImpl crossover;
  fatint::genetics::GeneticReproduction reproduction(mutation, crossover);
  fatint::genetics::ValidatorImpl validator;
  std::unique_ptr<fatint::genetics::IAlleleAdder> allele_adder;
  if (experiment_sweep_parameters.starting_parameters.run_parameters
        .allele_parameters.v_stretch > 0) {
    allele_adder = std::make_unique<fatint::genetics::VStretchAlleleAdder>();
  } else {
    allele_adder = std::make_unique<fatint::genetics::RandomAlleleAdder>();
  }
  fatint::measurement::DisjointSetsSpeciesCounter species_counter;

  fatint::simulation::ExperimentSweep experiment_sweep(
    experiment_sweep_parameters,
    similarity,
    selection,
    reproduction,
    validator,
    *allele_adder,
    species_counter);
  fatint::simulation::ExperimentSweepStates states = experiment_sweep.run();

  fatint::math::StatisticsEvaluator evaluator;
  fatint::simulation::ExperimentSweepResults results =
    evaluator.measure(experiment_sweep_parameters, states);

  std::streambuf* buf;
  std::ofstream of;
  if (output_file != "") {
    of.open(output_file);
    buf = of.rdbuf();
  } else {
    buf = std::cout.rdbuf();
  }
  std::ostream out(buf);

  if (format != "svg") {
    fatint::io::CSVWriter writer;
    writer.write(experiment_sweep_parameters, results, out);
  } else {
    fatint::io::SVGWriter writer;
    writer.write(experiment_sweep_parameters, results, out);
  }

  return 0;
}
