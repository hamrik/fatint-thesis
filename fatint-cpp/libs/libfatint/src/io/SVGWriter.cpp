#include "io/SVGWriter.hpp"

#include "simulation/types.hpp"
#include "simulation/utils.hpp"

namespace fatint::io {

/**
 * Generates an XY plot of the average species count for each experiment at
 * every step. Each experiment is graphed with a different color.
 *
 * @param params The parameters of the experiment sweep.
 * @param results The results of the experiment sweep.
 * @param dest The destination stream.
 */
void
SVGWriter::write(const simulation::ExperimentSweepParameters& params,
                 const simulation::ExperimentSweepResults& results,
                 std::ostream& dest)
{
  double width_with_padding = 1200;
  double height_with_padding = 600;
  double padding = 50;
  double legend_width = 400;
  double width = width_with_padding - padding * 2 - legend_width;
  double height = height_with_padding - padding * 2;

  int max_step = params.starting_parameters.run_parameters.steps;
  double max_value = 0;
  double mv_count = 0;
  for (const auto& experiment : results) {
    for (const auto& step : experiment) {
      max_value += step.species_count.avg;
      mv_count += 1;
    }
  }
  max_value /= mv_count;
  max_value *= 2;

  double step_width = width / params.starting_parameters.run_parameters.steps;
  double height_factor = height / max_value;
  double legend_height = height / params.experiments;

  simulation::ExperimentParameters experiment_params{
    params.starting_parameters
  };

  // SVG Header
  dest << "<svg version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" "
          "width=\""
       << width_with_padding << "\" height=\"" << height_with_padding
       << "\" viewbox=\"0 0 " << width_with_padding << " "
       << height_with_padding << "\">\n";

  // Plot backdrop and axes
  dest << "<rect x=\"0\" y=\"0\" width=\"" << width_with_padding
       << "\" height=\"" << height_with_padding << "\" fill=\"white\" />\n";
  dest << "<line x1=\"" << padding << "\" y1=\"" << padding << "\" x2=\""
       << padding << "\" y2=\"" << height + padding
       << "\" stroke=\"black\" />\n";
  dest << "<line x1=\"" << padding << "\" y1=\"" << height + padding
       << "\" x2=\"" << width + padding << "\" y2=\"" << height + padding
       << "\" stroke=\"black\" />\n";

  // Write axis labels
  dest << "<text text-anchor=\"middle\" transform=\"rotate(-90 " << padding / 2
       << " " << height_with_padding / 2 << ")\" x=\"" << padding / 2
       << "\" y=\"" << height_with_padding / 2 << "\">Average species count</text>\n";
  dest << "<text text-anchor=\"middle\" x=\"" << width / 2 + padding
       << "\" y=\"" << height + padding + padding / 2
       << "\">Step</text>\n";

  // Write axis extrema
  dest << "<text x=\"" << padding / 2 << "\" y=\""
       << height + padding + padding / 2 << "\">0</text>\n";
  dest << "<text text-anchor=\"end\" x=\"" << padding << "\" y=\""
       << padding / 2 << "\">" << max_value << "</text>\n";
  dest << "<text text-anchor=\"end\" x=\"" << width + padding << "\" y=\""
       << height + padding + padding / 2 << "\">" << max_step << "</text>\n";

  // Plot data points
  for (size_t e = 0; e < params.experiments; e++) {
    simulation::ExperimentResults experiment_results = results[e];
    double hue = e * 360.0 / params.experiments;
    // Plot legend
    dest << "<circle cx=\"" << width + padding + padding / 2 << "\" cy=\""
         << padding + legend_height * e - 5 << "\" r=\"3\" fill=\"hsl(" << hue
         << ", 75%, 50%)\" />\n";
    dest << "<text x=\"" << width + padding * 2 << "\" y=\""
         << padding + legend_height * e << "\">"
         << experiment_params.run_parameters << "</text>\n";
    for (size_t s = 0; s < max_step; s++) {
      simulation::Statistics step_statistics = experiment_results[s];
      double average_species_count = step_statistics.species_count.avg;
      double x = padding + s * step_width;
      double y = height + padding - average_species_count * height_factor;
      dest << "<circle cx=\"" << x << "\" cy=\"" << y
           << "\" r=\"1\" fill=\"hsl(" << hue << ", 75%, 50%)\" />\n";
    }
    experiment_params.run_parameters += params.delta;
  }

  dest << "</svg>\n";
}

}
