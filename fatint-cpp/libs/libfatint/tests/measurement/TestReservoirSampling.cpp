#include "math/Random.hpp"
#include "measurement/ReservoirSampling.hpp"

#include <map>

#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.hpp>

const size_t ITERATIONS = 1000;

TEST_CASE("ReservoirSampling - empty returns nullopt")
{
    fatint::measurement::ReservoirSampling<int> reservoir;

    auto result = reservoir.get();
    CHECK(!result.has_value());
}

TEST_CASE("ReservoirSampling - always picks single option")
{
    fatint::measurement::ReservoirSampling<int> reservoir;

    for(size_t i = 0; i < ITERATIONS; i++)
    {
        fatint::math::Random rng(i);

        reservoir.add(rng, 1);
        CHECK(reservoir.get().has_value());
        CHECK(reservoir.get().value() == 1);
    }
}

TEST_CASE("ReservoirSampling - reset works")
{
    fatint::measurement::ReservoirSampling<size_t> reservoir;

    for(size_t i = 0; i < ITERATIONS; i++)
    {
        fatint::math::Random rng(i);

        reservoir.add(rng, i);
        CHECK(reservoir.get().has_value());
        CHECK(reservoir.get().value() == i);

        reservoir.reset();
        CHECK(!reservoir.get().has_value());
    }
}

TEST_CASE("ReservoirSampling - deterministic given same seed")
{
    fatint::measurement::ReservoirSampling<size_t> reservoir1;
    fatint::measurement::ReservoirSampling<size_t> reservoir2;
    fatint::math::Random rng1(1);
    fatint::math::Random rng2(1);

    for (size_t i = 0; i < ITERATIONS; i++)
    {
        reservoir1.add(rng1, i);
        reservoir2.add(rng2, i);
    }

    auto res1 = reservoir1.get();
    auto res2 = reservoir2.get();

    CHECK(res1.has_value());
    CHECK(res2.has_value());
    CHECK(res1.value() == res2.value());
}


TEST_CASE("ReservoirSampling statistical behavior")
{
    const int ELEMENTS = 5;
    std::map<int, int> counts;

    for (size_t i = 0; i < ITERATIONS; i++)
    {
        fatint::measurement::ReservoirSampling<int> reservoir;
        fatint::math::Random rng(i);

        for (int i = 0; i < ELEMENTS; i++)
        {
            reservoir.add(rng, i);
        }

        auto result = reservoir.get();
        CHECK(result.has_value());

        counts[result.value()]++;
    }

    int min_count = INT_MAX;
    int max_count = 0;
    for (int i = 0; i < ELEMENTS; i++)
    {
        min_count = std::min(min_count, counts[i]);
        max_count = std::max(max_count, counts[i]);
    }

    int difference = max_count - min_count;

    // The difference between the least picked and most picked shall be <10%
    CHECK(difference < (ITERATIONS * ELEMENTS) / 10);
}
