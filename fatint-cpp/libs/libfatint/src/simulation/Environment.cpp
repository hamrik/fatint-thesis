#include "simulation/Environment.hpp"

#include <algorithm>

namespace fatint::simulation {

auto
Environment::take(int max) -> int
{
  max = std::min(energy, max);
  energy -= max;
  return max;
}

void
Environment::replenish(int amount)
{
  energy += amount;
}

auto
Environment::current_energy() const -> int
{
  return energy;
}

} // namespace fatint::simulation
