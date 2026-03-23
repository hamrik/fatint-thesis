
#pragma once

#include "io/IOutputWriter.hpp"
#include "simulation/types.hpp"
#include <ostream>

namespace fatint::io {

class SVGWriter : public IOutputWriter
{
public:
  void write(const simulation::ExperimentSweepParameters& params,
             const simulation::ExperimentSweepResults& results,
             std::ostream& dest) override;
};

} // namespace fatint::io
