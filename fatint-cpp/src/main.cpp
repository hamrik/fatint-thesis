#include "genetics/GeneticsImpl.hpp"
#include "genetics/genetics.hpp"
#include "io/CSVWriter.hpp"
#include "io/SVGWriter.hpp"
#include "math/Statistics.hpp"
#include "measurement/DepthFirstSearchSpeciesCounter.hpp"
#include "measurement/DisjointSetsSpeciesCounter.hpp"
#include "measurement/types.hpp"
#include "model/error.hpp"
#include "simulation/Simulator.hpp"
#include "simulation/types.hpp"

#include <algorithm>
#include <cmath>
#include <execution>
#include <fstream>
#include <iostream>
#include <memory>
#include <ostream>

#include <cxxopts.hpp>
#include <stdexcept>

template <typename T> auto def(const std::string &value)
{
    return cxxopts::value<T>()->default_value(value);
}

auto define_args(cxxopts::Options &options, int argc, char **argv) -> cxxopts::ParseResult
{
    auto opt = options.add_options();

    opt("r,runs", "Number of runs per experiment", def<unsigned int>("10"));
    opt("s,steps", "Number of iterations", def<unsigned int>("6000"));
    opt("S,seed", "Random seed", def<unsigned int>("1"));

    opt("m_init", "Initial population size", def<unsigned int>("100"));
    opt("n_init", "Initial number of genes", def<unsigned int>("5"));

    opt("p_encounter", "Probability of reproduction attempt", def<double>("0.1"));
    opt("p_change", "Probability of new gene per successful reproduction", def<double>("0.0"));
    opt("p_crossing", "Probability of crossover per gene", def<double>("0.2"));
    opt("p_mutation", "Probability of mutation per gene", def<double>("0.1"));

    opt("v_min", "Minimum allele (gene value)", def<int>("0"));
    opt("v_max", "Maximum allele (gene value)", def<int>("100"));
    opt("v_mutation", "Maximum gene mutation", def<int>("2"));
    opt("v_stretch",
        "Stretch factor when introducing new gene\n(0 = generate "
        "random gene)",
        def<double>("0.0"));

    opt("m_const", "Minimum number of offsprings per reproduction", def<double>("1"));
    opt("m_limit", "Maximum number of offsprings per reproduction", def<double>("15"));
    opt("m_slope", "How much should similarity affect offspring count", def<double>("0.0"));

    opt("e_increase",
        "Amount of energy the environment replenishes after "
        "each iteration",
        def<double>("1000.0"));
    opt("e_consumption", "Energy consumption per iteration", def<double>("5.0"));
    opt("e_intake", "Energy intake per iteration", def<double>("10.0"));
    opt("e_discount", "Energy discount per age", def<double>("0.9"));

    opt("dp,sweep_starting_population", "Initial population size delta", def<unsigned int>("0"));
    opt("dg,sweep_starting_gene_count", "Initial number of genes delta", def<unsigned int>("0"));

    opt("sweep",
        "The parameter to sweep. One of: "
        "m_init, n_init,"
        "p_encounter, p_crossing, p_mutation, p_change, "
        "v_min, v_max, v_mutaion, v_stretch, "
        "m_const, m_slope, m_limit, "
        "e_increase, e_intake, e_discount, e_consumption",
        cxxopts::value<std::string>());
    opt("sweep-from", "The starting value of the parameter sweep, inclusive", cxxopts::value<double>());
    opt("sweep-by", "The step size between parameter sweep values", def<double>("1"));
    opt("sweep-to", "The final value of the parameter sweep, inclusive", cxxopts::value<double>());

    opt("disjoint_sets", "Use Disjoint-Sets algorithm instead of Depth-First Search to count "
                         "species");
    opt("o,output", "Output file", def<std::string>(""));
    opt("f,format", "Output format", def<std::string>("csv"));

    opt("h,help", "Print help");

    return options.parse(argc, argv);
}

auto parse_args(cxxopts::ParseResult &result) -> fatint::simulation::ExperimentSweepParameters
{
    fatint::simulation::ExperimentSweepParameters experiment_sweep_parameters;
    fatint::simulation::ExperimentParameters experiment_parameters;
    fatint::simulation::RunParameters initial_run_parameters;
    fatint::simulation::RunParameters delta;

    memset(&delta, 0, sizeof(fatint::simulation::RunParameters));

    initial_run_parameters.steps = result["steps"].as<unsigned int>();
    initial_run_parameters.seed = result["seed"].as<unsigned int>();
    initial_run_parameters.reproduction_parameters.m_init = result["m_init"].as<unsigned int>();
    initial_run_parameters.genetic_parameters.n_init = result["n_init"].as<unsigned int>();

    initial_run_parameters.reproduction_probabilities.p_encounter = result["p_encounter"].as<double>();
    initial_run_parameters.reproduction_probabilities.p_change = result["p_change"].as<double>();
    initial_run_parameters.genetic_probabilities.p_crossing = result["p_crossing"].as<double>();
    initial_run_parameters.genetic_probabilities.p_mutation = result["p_mutation"].as<double>();

    initial_run_parameters.limits.v_min = result["v_min"].as<int>();
    initial_run_parameters.limits.v_max = result["v_max"].as<int>();
    initial_run_parameters.genetic_parameters.v_mutation = result["v_mutation"].as<int>();
    initial_run_parameters.genetic_parameters.v_stretch = result["v_stretch"].as<double>();

    initial_run_parameters.reproduction_parameters.m_const = result["m_const"].as<double>();
    initial_run_parameters.reproduction_parameters.m_slope = result["m_slope"].as<double>();

    initial_run_parameters.energy_parameters.e_increase = result["e_increase"].as<double>();
    initial_run_parameters.energy_parameters.e_consumption = result["e_consumption"].as<double>();
    initial_run_parameters.energy_parameters.e_intake = result["e_intake"].as<double>();
    initial_run_parameters.energy_parameters.e_discount = result["e_discount"].as<double>();

    if (result.contains("sweep") || result.contains("sweep-from") || result.contains("sweep-to"))
    {
        if (!(result.contains("sweep") && result.contains("sweep-from") && result.contains("sweep-to")))
        {
            throw std::runtime_error("--sweep, --sweep-from and --sweep-to are all required if either are set");
        }

        auto sweep_param = result["sweep"].as<std::string>();
        auto sweep_from = result["sweep-from"].as<double>();
        auto sweep_by = result["sweep-by"].as<double>();
        auto sweep_to = result["sweep-to"].as<double>();

        experiment_sweep_parameters.experiments = static_cast<size_t>((sweep_to - sweep_from) / sweep_by);

        // Hit the inclusive end if it can be hit cleanly
        if (std::remainder(sweep_to - sweep_from, sweep_by) < 0.00001)
        {
            experiment_sweep_parameters.experiments++;
        }

        if (sweep_param == "m_init")
        {
            initial_run_parameters.reproduction_parameters.m_init = static_cast<int>(sweep_from);
            delta.reproduction_parameters.m_init = static_cast<size_t>(sweep_by);
        }
        else if (sweep_param == "n_init")
        {
            initial_run_parameters.genetic_parameters.n_init = static_cast<int>(sweep_from);
            delta.genetic_parameters.n_init = static_cast<size_t>(sweep_by);
        }
        else if (sweep_param == "p_encounter")
        {
            initial_run_parameters.reproduction_probabilities.p_encounter = sweep_from;
            delta.reproduction_probabilities.p_encounter = sweep_by;
        }
        else if (sweep_param == "p_crossing")
        {
            initial_run_parameters.genetic_probabilities.p_crossing = sweep_from;
            delta.genetic_probabilities.p_crossing = sweep_by;
        }
        else if (sweep_param == "p_mutation")
        {
            initial_run_parameters.genetic_probabilities.p_mutation = sweep_from;
            delta.genetic_probabilities.p_mutation = sweep_by;
        }
        else if (sweep_param == "p_change")
        {
            initial_run_parameters.reproduction_probabilities.p_change = sweep_from;
            delta.reproduction_probabilities.p_change = sweep_by;
        }
        else if (sweep_param == "v_min")
        {
            initial_run_parameters.limits.v_min = static_cast<int>(sweep_from);
            delta.limits.v_min = static_cast<int>(sweep_by);
        }
        else if (sweep_param == "v_max")
        {
            initial_run_parameters.limits.v_max = static_cast<int>(sweep_from);
            delta.limits.v_max = static_cast<int>(sweep_by);
        }
        else if (sweep_param == "v_mutation")
        {
            initial_run_parameters.genetic_parameters.v_mutation = static_cast<int>(sweep_from);
        }
        else if (sweep_param == "v_stretch")
        {
            initial_run_parameters.genetic_parameters.v_stretch = sweep_from;
        }
        else if (sweep_param == "m_const")
        {
            initial_run_parameters.reproduction_parameters.m_const = sweep_from;
        }
        else if (sweep_param == "m_slope")
        {
            initial_run_parameters.reproduction_parameters.m_slope = sweep_from;
        }
        else if (sweep_param == "m_limit")
        {
            initial_run_parameters.reproduction_parameters.m_limit = sweep_from;
        }
        else if (sweep_param == "e_increase")
        {
            initial_run_parameters.energy_parameters.e_increase = sweep_from;
        }
        else if (sweep_param == "e_intake")
        {
            initial_run_parameters.energy_parameters.e_intake = sweep_from;
        }
        else if (sweep_param == "e_discount")
        {
            initial_run_parameters.energy_parameters.e_discount = sweep_from;
        }
        else if (sweep_param == "e_consumption")
        {
            initial_run_parameters.energy_parameters.e_consumption = sweep_from;
        }
    }
    else
    {
        experiment_sweep_parameters.experiments = 1;
    }

    experiment_parameters.run_parameters = initial_run_parameters;
    experiment_parameters.runs = result["runs"].as<unsigned int>();

    experiment_sweep_parameters.starting_parameters = experiment_parameters;
    experiment_sweep_parameters.delta = delta;

    experiment_sweep_parameters.validate();

    return experiment_sweep_parameters;
}

auto make_simulator(fatint::simulation::RunParameters params, bool use_disjoint_sets)
    -> std::unique_ptr<fatint::simulation::Simulator>
{
    fatint::genetics::EuclideanDistanceSimilarity similarity(params.reproduction_parameters);

    std::unique_ptr<fatint::genetics::IGeneAdder> gene_adder;
    if (params.genetic_parameters.v_stretch > 0)
    {
        gene_adder = std::make_unique<fatint::genetics::VStretchGeneAdder>(params.limits.v_min, params.limits.v_max,
                                                                           params.genetic_parameters.v_stretch);
    }
    else
    {
        gene_adder = std::make_unique<fatint::genetics::RandomGeneAdder>(params.limits.v_min, params.limits.v_max);
    }

    std::unique_ptr<fatint::measurement::ISpeciesCounter> species_counter;
    if (use_disjoint_sets)
    {
        species_counter = std::make_unique<fatint::measurement::DisjointSetsSpeciesCounter>(
            std::make_unique<fatint::genetics::EuclideanDistanceSimilarity>(similarity));
    }
    else
    {
        species_counter = std::make_unique<fatint::measurement::DepthFirstSearchSpeciesCounter>(
            std::make_unique<fatint::genetics::EuclideanDistanceSimilarity>(similarity));
    }

    return std::make_unique<fatint::simulation::Simulator>(
        std::make_unique<fatint::genetics::EuclideanDistanceSimilarity>(similarity),
        std::make_unique<fatint::genetics::ReservoirSelection>(
            std::make_unique<fatint::genetics::EuclideanDistanceSimilarity>(similarity)),
        std::make_unique<fatint::genetics::GeneticReproduction>(
            std::make_unique<fatint::genetics::BoundedMutation>(params.genetic_probabilities.p_mutation,
                                                                params.genetic_parameters.v_mutation),
            std::make_unique<fatint::genetics::Crossover>(params.genetic_probabilities.p_crossing), params.limits.v_min,
            params.limits.v_max),
        std::move(gene_adder), std::move(species_counter), params);
}

auto run_experiments(const fatint::simulation::ExperimentSweepParameters &experiment_sweep_parameters, bool use_ds)
    -> fatint::math::ExperimentSweepStatistics
{
    auto run_params = experiment_sweep_parameters.expand();
    std::vector<fatint::simulation::RunStates> run_results(run_params.size());
    std::transform(std::execution::par, run_params.begin(), run_params.end(), run_results.begin(),
                   [use_ds](const fatint::simulation::RunParameters &params) -> fatint::simulation::RunStates {
                       fatint::math::Random random(params.seed);
                       auto simulator = make_simulator(params, use_ds);
                       return simulator->run(random);
                   });
    fatint::math::ExperimentSweepStatistics results =
        fatint::math::measure(experiment_sweep_parameters, run_results);
    return results;
}

void write_results(const fatint::simulation::ExperimentSweepParameters &experiment_sweep_parameters,
                   const fatint::math::ExperimentSweepStatistics &results, const std::string &output_file,
                   const std::string &output_format)
{
    std::streambuf *buf = std::cout.rdbuf();
    std::ofstream of;
    if (output_file != "" && output_file != "-")
    {
        of.open(output_file);
        buf = of.rdbuf();
    }
    std::ostream out(buf);

    if (output_format != "svg")
    {
        fatint::io::CSVWriter writer;
        writer.write(experiment_sweep_parameters, results, out);
    }
    else
    {
        fatint::io::SVGWriter writer;
        writer.write(experiment_sweep_parameters, results, out);
    }
}

auto main(int argc, char **argv) -> int
{
    cxxopts::Options options(argv[0], "FATINT simulation");

    cxxopts::ParseResult opts;
    try
    {
        opts = define_args(options, argc, argv);
        if (opts.count("help"))
        {
            std::cerr << options.help() << '\n';
            exit(0);
        }
    }
    catch (const cxxopts::exceptions::exception &e)
    {
        std::cerr << "Error parsing arguments: " << e.what() << '\n';
        std::cerr << options.help() << '\n';
        exit(1);
    }

    fatint::simulation::ExperimentSweepParameters parameters;
    try {
         parameters = parse_args(opts);
    }
    catch (const fatint::error::ParameterConstraintException &e)
    {
        std::cerr << "Error while parsing options: " << e.what() << '\n';
        std::cerr << options.help() << '\n';
        exit(1);
    }
    catch (const std::runtime_error &e)
    {
        std::cerr << "Error while parsing options: " << e.what() << '\n';
        std::cerr << options.help() << '\n';
        exit(1);
    }
    catch (const cxxopts::exceptions::exception &e)
    {
        std::cerr << "Error while parsing options: " << e.what() << '\n';
        std::cerr << options.help() << '\n';
        exit(1);
    }

    auto use_ds = opts["disjoint_sets"].as<bool>();
    auto output_file = opts["output"].as<std::string>();
    auto output_format = opts["format"].as<std::string>();

    auto results = run_experiments(parameters, use_ds);

    write_results(parameters, results, output_file, output_format);

    return 0;
}
