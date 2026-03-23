#include "math/Statistics.hpp"

#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.hpp>

TEST_CASE("StatisticsEvaluator measures sample statistics accurately")
{
  fatint::math::StatisticsEvaluator evaluator;
  std::vector<double> values = { 1, 2, 3, 4, 5 };
  fatint::math::Measurement measurement = evaluator.measure(values);
  CHECK(measurement.min == 1);
  CHECK(measurement.max == 5);
  CHECK(measurement.avg == 3);
  CHECK(measurement.std == doctest::Approx(1.5811388300841898));
  CHECK(measurement.err == doctest::Approx(0.7071067811865476));
}
