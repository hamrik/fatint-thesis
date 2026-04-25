#pragma once

#include "simulation/types.hpp"

namespace fatint::simulation {

RunParameters&
operator+=(RunParameters& a, const RunParameters& b);

} // namespace fatint::simulation
