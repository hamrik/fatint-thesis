#pragma once

#include "simulation/types.hpp"

namespace fatint::simulation
{

auto operator+=(RunParameters &a, const RunParameters &b) -> RunParameters &;

} // namespace fatint::simulation
