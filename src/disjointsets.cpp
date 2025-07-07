#include "disjointsets.hpp"

DisjointSets::DisjointSets() {
  parents.reserve(1024);
  ranks.reserve(1024);
  root_count = 0;
}

void DisjointSets::clear() {
  parents.clear();
  ranks.clear();
  root_count = 0;
}

void DisjointSets::add() {
  parents.push_back(parents.size());
  ranks.push_back(0);
  root_count++;
}

unsigned int DisjointSets::find_root(unsigned int i) const {
  while (parents[i] != i) {
    i = parents[i] = parents[parents[i]]; // Path halving
  }
  return i;
}

void DisjointSets::merge(unsigned int a, unsigned int b) {
  a = find_root(a);
  b = find_root(b);

  if (a == b) {
    return;
  }

  if (ranks[a] < ranks[b]) {
    parents[a] = b;
  } else if (ranks[a] > ranks[b]) {
    parents[b] = a;
  } else {
    parents[b] = a;
    ranks[a]++;
  }

  root_count--;
}

bool DisjointSets::linked(unsigned int a, unsigned int b) const {
  return find_root(a) == find_root(b);
}

unsigned int DisjointSets::count() const {
  return root_count;
}
