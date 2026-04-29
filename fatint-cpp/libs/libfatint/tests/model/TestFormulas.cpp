#include "model/formulas.hpp"

#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.hpp>

TEST_CASE("entity_energy_change full intake when age 0")
{
    double change = fatint::model::entity_energy_change(0, 10.0, 0.9, 5.0);
    CHECK(change == doctest::Approx(5.0));
}

TEST_CASE("entity_energy_change discounted intake when aged")
{
    double change = fatint::model::entity_energy_change(1, 10.0, 0.9, 5.0);
    CHECK(change == doctest::Approx(4));

    change = fatint::model::entity_energy_change(2, 10.0, 0.9, 5.0);
    CHECK(change == doctest::Approx(3.1));

    change = fatint::model::entity_energy_change(10, 10.0, 0.9, 5.0);
    CHECK(change == doctest::Approx(-1.513216));
}

TEST_CASE("offspring_count calculation")
{
    int count = fatint::model::offspring_count(4.5, 5.0, 5.0, 1.0);
    CHECK(count == 4);
}

TEST_CASE("offspring_count with low similarity")
{
    int count = fatint::model::offspring_count(1.0, 5.0, 5.0, 1.0);
    CHECK(count == 1);
}

TEST_CASE("offspring_count can be zero or negative")
{
    // Very low similarity
    int count = fatint::model::offspring_count(0.0, 5.0, 5.0, 1.0);
    CHECK(count == 0); // floor(5.0 - 5.0 * 1.0) = floor(0.0) = 0

    // Negative case
    count = fatint::model::offspring_count(0.0, 5.0, 5.0, 2.0);
    CHECK(count == -5); // floor(5.0 - 5.0 * 2.0) = floor(-5.0) = -5
}

TEST_CASE("stretch_genes basic wrapping")
{
    // last_gene=5, v_min=0, v_max=10, v_stretch=1.0
    int result = fatint::model::stretch_gene(5, 0, 10, 1.0);
    CHECK(result == 5); // 0 + floor(5 * 1.0) % 11 = 0 + 5 = 5
}

TEST_CASE("stretch_gene with stretching factor")
{
    // Stretch factor of 2.0 doubles the value
    int result = fatint::model::stretch_gene(5, 0, 10, 2.0);
    CHECK(result == 10); // 0 + floor(5 * 2.0) % 11 = 0 + 10 = 10
}

TEST_CASE("stretch_gene wraps around")
{
    // Should wrap around when stretched value exceeds max
    int result = fatint::model::stretch_gene(10, 0, 10, 2.0);
    CHECK(result == 9); // 0 + floor(10 * 2.0) % 11 = 0 + 20 % 11 = 9
}

TEST_CASE("stretch_gene with offset min")
{
    // v_min is not zero
    int result = fatint::model::stretch_gene(5, 10, 20, 1.0);
    CHECK(result == 15); // 10 + floor(5 * 1.0) % 11 = 10 + 5 = 15
}
