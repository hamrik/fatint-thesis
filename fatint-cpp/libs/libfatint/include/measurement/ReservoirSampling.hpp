#pragma once

#include "math/Random.hpp"
#include <optional>

namespace fatint::measurement {

template<typename T>
class ReservoirSampling
{
public:
  ReservoirSampling();
  ~ReservoirSampling();

  void add(math::Random& random, T t);

  std::optional<T> get();

  void reset();

private:
  std::optional<T> current;
  size_t n = 0;
};

} // namespace fatint::measurement

#include "ReservoirSampling.tpp"
