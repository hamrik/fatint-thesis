#pragma once

#include "math/Random.hpp"

namespace fatint::math
{

class Range
{
    public:
    Range(int lower_incl, int upper_incl);
    auto pick(Random &rng) -> int;
    auto includes(int value) -> bool;

    private:
    int lower_incl;
    int upper_incl;
};

class Probability
{
  public:
    Probability(double p);
    auto chance(Random &rng) -> bool;

  private:
    double p;
};

struct Measurement
{
    double min;
    double max;
    double avg;
    double std;
    double err;
};

} // namespace fatint::math
