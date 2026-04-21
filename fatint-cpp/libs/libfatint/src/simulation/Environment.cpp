#include "simulation/Environment.hpp"

#include <algorithm>

namespace fatint::simulation {

auto
Environment::take(double max) -> double
{
  max = std::min(energy, max);
  energy -= max;
  return max;
}

void
Environment::replenish(double amount)
{
  energy += amount;
}

auto
Environment::current_energy() const -> double
{
  return energy;
}

} // namespace fatint::simulation
