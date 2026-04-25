#pragma once

#include "simulation/types.hpp"

#include <ostream>

namespace fatint::io
{

class IOutputWriter
{
  public:
    virtual ~IOutputWriter() = default;
    virtual void write(const simulation::ExperimentSweepParameters &params,
                       const simulation::ExperimentSweepResults &results, std::ostream &dest) = 0;
};

} // namespace fatint::io
