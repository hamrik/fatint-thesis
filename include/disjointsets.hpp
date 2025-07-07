#pragma once

#include <vector>

class DisjointSets {
private:
  mutable std::vector<unsigned int> parents;
  std::vector<unsigned int> ranks;
  unsigned int root_count;
  unsigned int find_root(unsigned int i) const;
public:
  DisjointSets();
  void clear();
  void add();
  void merge(unsigned int a, unsigned int b);
  bool linked(unsigned int a, unsigned int b) const;
  unsigned int count() const;
};
