#include "model/utils.hpp"

#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.hpp>

TEST_CASE("Limits operator+= accumulates values")
{
    fatint::model::Limits a;
    a.v_min = 0;
    a.v_max = 10;
    a.m_limit = 5.0;
    fatint::model::Limits b;
    b.v_min = 1;
    b.v_max = 5;
    b.m_limit = 2.0;

    a += b;

    CHECK(a.v_min == 1);
    CHECK(a.v_max == 15);
    CHECK(a.m_limit == doctest::Approx(7.0));
}

TEST_CASE("ReproductionProbabilities operator+= accumulates values")
{
    fatint::model::ReproductionProbabilities a;
    a.p_encounter = 0.1;
    a.p_change = 0.2;
    fatint::model::ReproductionProbabilities b;
    b.p_encounter = 0.05;
    b.p_change = 0.1;

    a += b;

    CHECK(a.p_encounter == doctest::Approx(0.15));
    CHECK(a.p_change == doctest::Approx(0.3));
}

TEST_CASE("ReproductionParameters operator+= accumulates values")
{
    fatint::model::ReproductionParameters a;
    a.starting_population = 100;
    a.m_const = 2.0;
    a.m_slope = 0.5;
    fatint::model::ReproductionParameters b;
    b.starting_population = 50;
    b.m_const = 1.0;
    b.m_slope = 0.25;

    a += b;

    CHECK(a.starting_population == 150);
    CHECK(a.m_const == doctest::Approx(3.0));
    CHECK(a.m_slope == doctest::Approx(0.75));
}

TEST_CASE("GeneticProbabilities operator+= accumulates values")
{
    fatint::model::GeneticProbabilities a;
    a.p_crossing = 0.3;
    a.p_mutation = 0.4;
    fatint::model::GeneticProbabilities b;
    b.p_crossing = 0.2;
    b.p_mutation = 0.1;

    a += b;

    CHECK(a.p_crossing == doctest::Approx(0.5));
    CHECK(a.p_mutation == doctest::Approx(0.5));
}

TEST_CASE("AlleleParameters operator+= accumulates values")
{
    fatint::model::AlleleParameters a;
    a.starting_allele_count = 10;
    a.v_mutation = 1;
    a.v_stretch = 1.5;
    fatint::model::AlleleParameters b;
    b.starting_allele_count = 5;
    b.v_mutation = 1;
    b.v_stretch = 0.25;

    a += b;

    CHECK(a.starting_allele_count == 15);
    CHECK(a.v_mutation == doctest::Approx(2));
    CHECK(a.v_stretch == doctest::Approx(1.75));
}

TEST_CASE("EnergyParameters operator+= accumulates values")
{
    fatint::model::EnergyParameters a;
    a.e_increase = 10.0;
    a.e_consumption = 1.0;
    a.e_intake = 5.0;
    a.e_discount = 0.9;
    fatint::model::EnergyParameters b;
    b.e_increase = 5.0;
    b.e_consumption = 0.5;
    b.e_intake = 2.0;
    b.e_discount = 0.05;

    a += b;

    CHECK(a.e_increase == doctest::Approx(15.0));
    CHECK(a.e_consumption == doctest::Approx(1.5));
    CHECK(a.e_intake == doctest::Approx(7.0));
    CHECK(a.e_discount == doctest::Approx(0.95));
}

TEST_CASE("Chained operator+= works correctly")
{
    fatint::model::Limits a;
    a.v_min = 0;
    a.v_max = 10;
    a.m_limit = 5.0;
    fatint::model::Limits b;
    b.v_min = 1;
    b.v_max = 5;
    b.m_limit = 2.0;
    fatint::model::Limits c;
    c.v_min = 2;
    c.v_max = 3;
    c.m_limit = 1.0;

    a += b;
    a += c;

    CHECK(a.v_min == 3);
    CHECK(a.v_max == 18);
    CHECK(a.m_limit == doctest::Approx(8.0));
}
