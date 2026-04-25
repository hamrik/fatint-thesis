#include "math/Random.hpp"

#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <algorithm>
#include <doctest.hpp>

TEST_CASE("Random seeding produces deterministic results")
{
  fatint::math::Random rng1(42);
  fatint::math::Random rng2(42);

  // Same seed should produce same results
  for (int i = 0; i < 1000; i++) {
    CHECK(rng1.random(0, 100) == rng2.random(0, 100));
  }
}

TEST_CASE("Random reseeding works")
{
  fatint::math::Random rng;

  rng.seed(123);
  int first = rng.random(0, 1000);

  rng.seed(123);
  int second = rng.random(0, 1000);

  CHECK(first == second);
}

TEST_CASE("Random integer range is correct")
{
  fatint::math::Random rng(42);

  bool seen_10 = false;
  bool seen_20 = false;

  for (int i = 0; i < 1000; i++) {
    int value = rng.random(10, 20);
    CHECK(value >= 10);
    CHECK(value <= 20);
    if (value == 10)
      seen_10 = true;
    if (value == 20)
      seen_20 = true;
  }

  CHECK(seen_10);
  CHECK(seen_20);
}

TEST_CASE("Random double range is correct")
{
  fatint::math::Random rng(42);

  for (int i = 0; i < 1000; i++) {
    double value = rng.random(0.0, 1.0);
    CHECK(value >= 0.0);
    CHECK(value < 1.0);
  }
}

TEST_CASE("Random chance with probability 0.0 always returns false")
{
  fatint::math::Random rng(42);

  for (int i = 0; i < 1000; i++) {
    CHECK(rng.chance(0.0) == false);
  }
}

TEST_CASE("Random chance with probability 1.0 always returns true")
{
  fatint::math::Random rng(42);

  for (int i = 0; i < 1000; i++) {
    CHECK(rng.chance(1.0) == true);
  }
}

TEST_CASE("Random chance with probability 0.5 produces mixed results")
{
  fatint::math::Random rng(42);

  int true_count = 0;
  int total = 1000;

  for (int i = 0; i < total; i++) {
    if (rng.chance(0.5)) {
      true_count++;
    }
  }

  // Should be roughly 50% true (allow +-5% tolerance)
  CHECK(true_count > total * 0.45);
  CHECK(true_count < total * 0.55);
}

TEST_CASE("Random shuffles correctly")
{
  fatint::math::Random rng(42);

  std::vector<size_t> v = rng.random_indices(5);
  CHECK(v != std::vector<size_t>({ 0, 1, 2, 3, 4 }));
  std::ranges::sort(v);
  CHECK(v == std::vector<size_t>({ 0, 1, 2, 3, 4 }));
}
