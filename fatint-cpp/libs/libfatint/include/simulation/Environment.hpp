#pragma once

namespace fatint::simulation {

class Environment
{
public:
  int take(int max);
  void replenish(int amount);
  int current_energy() const;

private:
  int energy = 0;
};

} // namespace fatint::simulation
