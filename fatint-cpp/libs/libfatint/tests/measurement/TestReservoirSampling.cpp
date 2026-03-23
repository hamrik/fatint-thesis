#include "math/Random.hpp"
#include "measurement/ReservoirSampling.hpp"

#include <map>

#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.hpp>

TEST_CASE("ReservoirSampling starts empty")
{
  fatint::measurement::ReservoirSampling<int> reservoir;

  auto result = reservoir.get();
  CHECK(!result.has_value());
}

TEST_CASE("ReservoirSampling reset works")
{
  fatint::measurement::ReservoirSampling<int> reservoir;
  fatint::math::Random rng(42);

  reservoir.add(rng, 42);
  // After adding one element, there's a chance it was selected
  reservoir.reset();
  // After reset, should be empty
  CHECK(!reservoir.get().has_value());
}

TEST_CASE("ReservoirSampling with deterministic seed")
{
  fatint::measurement::ReservoirSampling<int> reservoir1;
  fatint::measurement::ReservoirSampling<int> reservoir2;
  fatint::math::Random rng1(123);
  fatint::math::Random rng2(123);

  // Add same sequence with same seed
  for (int i = 0; i < 100; i++) {
    reservoir1.add(rng1, i);
    reservoir2.add(rng2, i);
  }

  // Should get same result with same seed
  auto res1 = reservoir1.get();
  auto res2 = reservoir2.get();

  // Both should either have or not have a value
  CHECK(res1.has_value() == res2.has_value());
  if (res1.has_value() && res2.has_value()) {
    CHECK(res1.value() == res2.value());
  }
}

TEST_CASE("ReservoirSampling works with different types")
{
  SUBCASE("double")
  {
    fatint::measurement::ReservoirSampling<double> reservoir;
    fatint::math::Random rng(42);

    reservoir.add(rng, 3.14);
    reservoir.add(rng, 2.71);

    auto result = reservoir.get();
    // May or may not have a value depending on random choices
    if (result.has_value()) {
      CHECK((result.value() == doctest::Approx(3.14) ||
             result.value() == doctest::Approx(2.71)));
    }
  }

  SUBCASE("string")
  {
    fatint::measurement::ReservoirSampling<std::string> reservoir;
    fatint::math::Random rng(42);

    reservoir.add(rng, "hello");
    reservoir.add(rng, "world");

    auto result = reservoir.get();
    // May or may not have a value
    if (result.has_value()) {
      CHECK((result.value() == "hello" || result.value() == "world"));
    }
  }
}

TEST_CASE("ReservoirSampling statistical behavior")
{
  fatint::math::Random rng(42);

  // Count how often each element appears when selected
  std::map<int, int> counts;
  const int trials = 10000;
  const int elements = 5;

  for (int trial = 0; trial < trials; trial++) {
    fatint::measurement::ReservoirSampling<int> reservoir;
    fatint::math::Random trial_rng(rng.random(0, 1000000));

    for (int i = 0; i < elements; i++) {
      reservoir.add(trial_rng, i);
    }

    auto result = reservoir.get();
    if (result.has_value()) {
      counts[result.value()]++;
    }
  }

  // Check that we got some samples
  int total_samples = 0;
  for (int i = 0; i < elements; i++) {
    total_samples += counts[i];
  }

  // Should have selected something in most trials
  CHECK(total_samples > trials * 0.3);
}
