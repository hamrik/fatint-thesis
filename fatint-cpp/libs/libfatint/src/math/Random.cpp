#include "math/Random.hpp"

#include <algorithm>
#include <random>

namespace fatint::math {

struct Random::impl
{
  std::mt19937_64 rng;
};

Random::Random()
  : pimpl(std::make_unique<impl>())
{
}
Random::Random(size_t seed)
  : pimpl(std::make_unique<impl>())
{
  this->seed(seed);
}
Random::~Random() = default;

void
Random::seed(size_t seed)
{
  pimpl->rng.seed(seed);
}
auto
Random::random(int min, int max) -> int
{
  return std::uniform_int_distribution<>(min, max)(pimpl->rng);
}
auto
Random::random(double min, double max_excl) -> double
{
  return std::uniform_real_distribution<>(min, max_excl)(pimpl->rng);
}
auto
Random::chance(double p) -> bool
{
  return random(0.0, 1.0) < p;
}
void
Random::shuffle(std::vector<size_t>& v)
{
  std::shuffle(v.begin(), v.end(), pimpl->rng);
}
auto
Random::random_indices(size_t count) -> std::vector<size_t>
{
  std::vector<size_t> v(count);
  std::iota(v.begin(), v.end(), 0);
  shuffle(v);
  return v;
}

} // namespace fatint::math
