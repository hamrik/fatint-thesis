#pragma once

#include "disjointsets.hpp"
#include <random>
#include <vector>

typedef struct {
  int runs;
  int steps;
  int seed;
  double starting_population;
  double starting_gene_count;

  double p_encounter;
  double p_change;
  double p_crossing;
  double p_mutation;

  double v_min;
  double v_max;
  double v_mutation;
  double v_stretch;

  double m_const;
  double m_limit;
  double m_slope;

  double e_increase;
  double e_consumption;
  double e_intake;
  double e_discount;
} Parameters;

typedef struct {
  unsigned long int id;
  unsigned int age;
  double energy;
  std::vector<int> genotype;
} Entity;

class Population {
private:
  const Parameters params;
  unsigned long similarity_threshold_squared;

  DisjointSets species;
  std::vector<Entity> current, next;
  std::mt19937 rng;

  unsigned long counter;
  unsigned long allele_count;
  double available_energy;

  bool compatible(const Entity &a, const Entity &b) const;
  bool simulate();
  void prune();
  void combine(const Entity &a, const Entity &b);
  void add_random_gene();
  void add_stretched_gene();
  void reproduce();

public:
  Population(Parameters params);
  void add_random();
  void tick();
  int count_entities();
  int count_genes();
  int count_species();
};
