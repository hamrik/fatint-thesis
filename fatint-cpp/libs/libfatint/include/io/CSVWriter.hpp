#pragma once

#include "io/IOutputWriter.hpp"
#include "simulation/types.hpp"
#include <ostream>

namespace fatint::io {

class CSVWriter : public IOutputWriter
{
public:
  void write(const simulation::ExperimentParameters& params,
             const simulation::ExperimentResults& results,
             std::ostream& dest);
  void write(const simulation::ExperimentSweepParameters& params,
             const simulation::ExperimentSweepResults& results,
             std::ostream& dest) override;

private:
  void write_header(const simulation::ExperimentParameters& params,
                    std::ostream& dest);
  void write_row(size_t step,
                 const simulation::ExperimentParameters& params,
                 const simulation::Statistics& result,
                 std::ostream& dest);
};

} // namespace fatint::io
