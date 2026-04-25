#pragma once

#include <cstddef>
#include <memory>
#include <vector>

namespace fatint::math
{

class Random
{
  public:
    Random();
    Random(size_t seed);
    ~Random();

    void seed(size_t seed);
    auto chance(double p) -> bool;
    auto random(int min, int max) -> int;
    auto random(double min, double max) -> double;
    void shuffle(std::vector<size_t> &v);
    auto random_indices(size_t count) -> std::vector<size_t>;

  private:
    struct impl;
    std::unique_ptr<impl> pimpl;
};

} // namespace fatint::math
