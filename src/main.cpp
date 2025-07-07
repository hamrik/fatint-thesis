#include "population.hpp"

#include <algorithm>
#include <cmath>
#include <execution>
#include <ios>
#include <iostream>

#include "cxxopts.hpp"

template <typename T> auto def(std::string value) {
  return cxxopts::value<T>()->default_value(value);
}

Parameters parse_args(int argc, char **argv) {
  try {
    cxxopts::Options options(argv[0], "FATINT simulation");

    auto opt = options.add_options();
    opt("r,runs", "Number of runs", def<int>("10"));
    opt("s,steps", "Number of iterations", def<int>("6000"));
    opt("S,seed", "Random seed", def<int>("1"));
    opt("p,starting_population", "Initial population size",
         def<double>("100"));
    opt("g,starting_gene_count", "Initial number of genes", def<double>("5"));

    opt("p_encounter", "Probability of reproduction attempt",
         def<double>("0.1"));
    opt("p_change", "Probability of new gene per successful reproduction",
         def<double>("0.0"));
    opt("p_crossing", "Probability of crossover per gene", def<double>("0.2"));
    opt("p_mutation", "Probability of mutation per gene", def<double>("0.1"));

    opt("v_min", "Minimum allele", def<double>("0"));
    opt("v_max", "Maximum allele", def<double>("100"));
    opt("v_mutation", "Maximum allele mutation", def<double>("2"));
    opt("v_stretch",
         "Stretch factor when introducing new gene\n(0 = generate "
         "random gene)",
         def<double>("0.0"));

    opt("m_const", "Minimum number of offsprings per reproduction",
         def<double>("1"));
    opt("m_limit", "Maximum number of offsprings per reproduction",
         def<double>("15"));
    opt("m_slope", "How much should similarity affect offspring count",
         def<double>("0.0"));

    opt("e_increase",
         "Amount of energy the environment replenishes after "
         "each iteration",
         def<double>("1000.0"));
    opt("e_consumption", "Energy consumption per iteration",
         def<double>("5.0"));
    opt("e_intake", "Energy intake per iteration", def<double>("10.0"));
    opt("e_discount", "Energy discount per age", def<double>("0.9"));

    opt("h,help", "Print help");

    auto result = options.parse(argc, argv);

    if (result.count("help")) {
      std::cout << options.help() << std::endl;
      exit(0);
    }

    // Construct the struct at the end using the parsed values (or defaults).
    Parameters params{
        .runs = result["runs"].as<int>(),
        .steps = result["steps"].as<int>(),
        .seed = result["seed"].as<int>(),
        .starting_population = result["starting_population"].as<double>(),
        .starting_gene_count = result["starting_gene_count"].as<double>(),

        .p_encounter = result["p_encounter"].as<double>(),
        .p_change = result["p_change"].as<double>(),
        .p_crossing = result["p_crossing"].as<double>(),
        .p_mutation = result["p_mutation"].as<double>(),

        .v_min = result["v_min"].as<double>(),
        .v_max = result["v_max"].as<double>(),
        .v_mutation = result["v_mutation"].as<double>(),
        .v_stretch = result["v_stretch"].as<double>(),

        .m_const = result["m_const"].as<double>(),
        .m_limit = result["m_limit"].as<double>(),
        .m_slope = result["m_slope"].as<double>(),

        .e_increase = result["e_increase"].as<double>(),
        .e_consumption = result["e_consumption"].as<double>(),
        .e_intake = result["e_intake"].as<double>(),
        .e_discount = result["e_discount"].as<double>(),
    };

    return params;

  } catch (const cxxopts::exceptions::exception &e) {
    std::cerr << "Error parsing options: " << e.what() << std::endl;
    exit(1);
  }
}

typedef struct {
  int population;
  int gene_count;
  int species;
} Status;

typedef struct {
  double average, min, max;
  double standard_deviation;
  double standard_error;
} Measurement;

typedef struct {
  Measurement population;
  Measurement gene_count;
  Measurement species;
} Statistics;

std::vector<Status> run(const Parameters &params) {
  Population pop{params};
  std::vector<Status> status;
  status.reserve(params.steps);

  for (int step = 0; step < params.steps; step++) {
    pop.tick();
    Status current{.population = pop.count_entities(),
                   .gene_count = pop.count_genes(),
                   .species = pop.count_species()};
    status.push_back(current);
  }

  return status;
}

std::vector<Statistics> compile_results(Parameters params, std::vector<std::vector<Status>> results)
{
  std::vector<Statistics> statistics(params.steps);

  for (int s = 0; s < params.steps; s++) {
    statistics[s].population.min = results[0][s].population;
    statistics[s].gene_count.min = results[0][s].gene_count;
    statistics[s].species.min = results[0][s].species;
    statistics[s].population.max = results[0][s].population;
    statistics[s].gene_count.max = results[0][s].gene_count;
    statistics[s].species.max = results[0][s].species;
    for (int r = 0; r < params.runs; r++) {
      statistics[s].population.average += results[r][s].population;
      statistics[s].gene_count.average += results[r][s].gene_count;
      statistics[s].species.average += results[r][s].species;
      statistics[s].population.min = std::min(statistics[s].population.min, (double)results[r][s].population);
      statistics[s].gene_count.min = std::min(statistics[s].gene_count.min, (double)results[r][s].gene_count);
      statistics[s].species.min = std::min(statistics[s].species.min, (double)results[r][s].species);
      statistics[s].population.max = std::max(statistics[s].population.max, (double)results[r][s].population);
      statistics[s].gene_count.max = std::max(statistics[s].gene_count.max, (double)results[r][s].gene_count);
      statistics[s].species.max = std::max(statistics[s].species.max, (double)results[r][s].species);
    }
    statistics[s].population.average /= params.runs;
    statistics[s].gene_count.average /= params.runs;
    statistics[s].species.average /= params.runs;
  }

  for (int s = 0; s < params.steps; s++) {
    for (int r = 0; r < params.runs; r++) {
      double d_pop =
          results[r][s].population - statistics[r].population.average;
      double d_gene =
          results[r][s].gene_count - statistics[r].gene_count.average;
      double d_spec = results[r][s].species - statistics[r].species.average;
      statistics[s].population.standard_deviation += d_pop * d_pop;
      statistics[s].gene_count.standard_deviation += d_gene * d_gene;
      statistics[s].species.standard_deviation += d_spec * d_spec;
    }
    statistics[s].population.standard_deviation =
        std::sqrt(statistics[s].population.standard_deviation / params.runs);
    statistics[s].gene_count.standard_deviation =
        std::sqrt(statistics[s].gene_count.standard_deviation / params.runs);
    statistics[s].species.standard_deviation =
        std::sqrt(statistics[s].species.standard_deviation / params.runs);
    statistics[s].population.standard_error =
        statistics[s].population.standard_deviation / sqrt(params.runs);
    statistics[s].gene_count.standard_error =
        statistics[s].gene_count.standard_deviation / sqrt(params.runs);
    statistics[s].species.standard_error =
        statistics[s].species.standard_deviation / sqrt(params.runs);
  }

  return statistics;
}

int main(int argc, char **argv) {
  std::ios_base::sync_with_stdio(false);
  std::cin.tie(nullptr);

  Parameters params = parse_args(argc, argv);
  std::vector<Parameters> runs;
  runs.reserve(params.runs);
  for (int i = 0; i < params.runs; i++) {
    Parameters p = params;
    p.seed += i;
    runs.push_back(p);
  }

  std::vector<std::vector<Status>> results(params.runs);
  std::transform(std::execution::par, runs.begin(), runs.end(),
                 results.begin(), run);

  auto statistics = compile_results(params, results);

  std::cout
      << "Step,GeneCountMin,GeneCountMax,GeneCountAvg,GeneCountSE,"
      << "PopMin,PopMax,PopAvg,PopSE,"
      << "SpeciesMin,SpeciesMax,SpeciesAvg,SpeciesSE";
  for (int r = 1; r <= params.runs; r++) {
    std::cout
        << ",GeneCount" << r
        << ",Pop" << r
        << ",Species" << r;
  }
  std::cout << "\n";
  for (int s = 0; s < params.steps; s++) {
    std::cout << (s + 1) << ","
              << statistics[s].gene_count.min << ","
              << statistics[s].gene_count.max << ","
              << statistics[s].gene_count.average << ","
              << statistics[s].gene_count.standard_error << ","
              << statistics[s].population.min<< ","
              << statistics[s].population.max << ","
              << statistics[s].population.average << ","
              << statistics[s].population.standard_error << ","
              << statistics[s].species.min<< ","
              << statistics[s].species.max << ","
              << statistics[s].species.average << ","
              << statistics[s].species.standard_error;
    for(int r = 0; r < params.runs; r++) {
        std::cout
            << "," << results[r][s].gene_count
            << "," << results[r][s].population
            << "," << results[r][s].species;
    }
    std::cout << "\n";
  }
  std::cout.flush();

  return 0;
}
