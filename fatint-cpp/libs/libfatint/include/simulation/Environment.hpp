#pragma once

namespace fatint::simulation {

class Environment
{
public:
  auto take(double max) -> double;
  void replenish(double amount);
  auto current_energy() const -> double;

private:
  double energy = 0.0;
};

} // namespace fatint::simulation
