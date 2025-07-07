#include "population.hpp"

#include <optional>
#include <algorithm>

unsigned long eucledian_distance_squared(const Entity &a,
                                         const Entity &b) {
  long dist = 0;
  for (int i = 0; i < a.genotype.size(); i++) {
    long d = a.genotype[i] - b.genotype[i];
    dist += d * d;
  }
  return (unsigned long)dist;
}

bool Population::compatible(const Entity &a, const Entity &b) const {
  return eucledian_distance_squared(a, b) < similarity_threshold_squared;
}

bool Population::simulate() {
  bool pruning_required = false;
  available_energy += params.e_increase;
  std::vector<int> indices(current.size());
  std::iota(indices.begin(), indices.end(), 0);
  std::shuffle(indices.begin(), indices.end(), rng);
  for (int i = current.size() - 1; i >= 0; i--) {
    auto &entity = current[indices[i]];
    double energy_taken = fmin(params.e_intake, available_energy);
    available_energy -= energy_taken;
    entity.energy += energy_taken * pow(params.e_discount, entity.age);
    entity.energy -= params.e_consumption;
    if (entity.energy <= 0) {
      pruning_required = true;
    }
    entity.age++;
  }
  return pruning_required;
}

void Population::prune() {
  next.clear();
  species.clear();
  for (const auto &entity : current) {
    if (entity.energy >= 0) {
      next.push_back(entity);
      species.add();
    }
  }
  current.swap(next);
}

void Population::combine(const Entity &a, const Entity &b) {
  std::uniform_real_distribution<> chance(0.0, 1.0);
  std::uniform_int_distribution<> mutation(-params.v_mutation,
                                           params.v_mutation + 1);

  std::vector<int> genotype;
  genotype.reserve(a.genotype.size());

  for (int i = 0; i < a.genotype.size(); i++) {
    int gene = chance(rng) < params.p_crossing ? b.genotype[i] : a.genotype[i];
    if (chance(rng) < params.p_mutation) {
      gene += mutation(rng);
    }
    genotype.push_back(gene);
  }

  Entity entity{
      .id = counter++,
      .age = 0,
      .energy = 0,
      .genotype = genotype,
  };
  current.push_back(entity);
  species.add();
}

void Population::add_random_gene() {
  std::uniform_int_distribution<> v(params.v_min, params.v_max + 1);
  for (auto &entity : current) {
    entity.genotype.push_back(v(rng));
  }
  allele_count++;
}

void Population::add_stretched_gene() {
  for (auto &entity : current) {
    long last = entity.genotype[entity.genotype.size() - 1];
    long gene = (long)(last * params.v_stretch) % (long)(params.v_max - params.v_min + 1);
    entity.genotype.push_back(gene);
  }
  allele_count++;
}

void Population::reproduce() {
  std::uniform_real_distribution<> dis(0.0, 1.0);
  unsigned long orig_size = current.size();
  int new_genes = 0;
  for (int i = 0; i < orig_size; i++) {
    auto &entity = current[i];
    if (dis(rng) < params.p_encounter) {
      double n = 1;
      std::optional<Entity> partner;
      for (int j = 0; j < orig_size; j++) {
        auto &other = current[j];
        if (other.id != entity.id && compatible(entity, other) &&
            dis(rng) * n < 1) {
          partner = other;
          n++;
        }
      }
      if (partner.has_value()) {
        combine(entity, partner.value());
        if (dis(rng) < params.p_change) {
          new_genes++;
        }
      }
    }
  }
  for (int i = 0; i < new_genes; i++) {
    if(params.v_stretch == 0) {
      add_random_gene(); // TODO: stretch method
    } else {
      add_stretched_gene();
    }
  }
}

int Population::count_species() {
  for (int i = 0; i < current.size(); i++) {
    for (int j = i + 1; j < current.size(); j++) {
      if (!species.linked(i,j) && compatible(current[i], current[j])) {
        species.merge(i, j);
      }
    }
  }
  return species.count();
}

Population::Population(Parameters params) : params(params) {
  rng.seed(params.seed);

  counter = 0;
  similarity_threshold_squared = params.m_limit * params.m_limit;

  allele_count = params.starting_gene_count;
  for (int i = 0; i < params.starting_population; i++) {
    add_random();
  }
}

void Population::add_random() {
  Entity entity{
      .id = counter++,
      .age = 0,
      .energy = 0,
  };
  std::uniform_int_distribution<> d(params.v_min, params.v_max);
  for (int a = 0; a < allele_count; a++) {
    entity.genotype.push_back(d(rng));
  }
  current.push_back(entity);
  species.add();
}

void Population::tick() {
  bool pruning_required = simulate();
  if (pruning_required) {
    prune();
  }
  reproduce();
}

int Population::count_entities() { return current.size(); }

int Population::count_genes() { return allele_count; }
