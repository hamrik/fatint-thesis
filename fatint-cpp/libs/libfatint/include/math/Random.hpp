#pragma once

#include <cstddef>
#include <memory>
#include <vector>

namespace fatint::math {

class Random
{
public:
  Random();
  Random(size_t seed);
  ~Random();

  void seed(size_t seed);
  bool chance(double p);
  int random(int min, int max);
  double random(double min, double max);
  void shuffle(std::vector<size_t>& v);
  std::vector<size_t> random_indices(size_t count);

private:
  struct impl;
  std::unique_ptr<impl> pimpl;
};

} // namespace fatint::math
