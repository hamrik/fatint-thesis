#include "measurement/DisjointSetsSpeciesCounter.hpp"
#include "genetics/genetics.hpp"
#include <cassert>
#include <memory>

namespace fatint::measurement
{

class DisjointSets
{
  private:
    mutable std::vector<size_t> parents;
    std::vector<size_t> ranks;
    size_t root_count;

  public:
    DisjointSets(size_t cap) : root_count(cap)
    {
        reset(cap);
    }
    void reset(size_t cap)
    {
        parents.clear();
        ranks.clear();
        parents.reserve(cap);
        ranks.reserve(cap);
        for (size_t i = 0; i < cap; i++)
        {
            parents.push_back(i);
            ranks.push_back(0);
        }
        root_count = cap;
    };
    void link(size_t a, size_t b)
    {
        a = find_root(a);
        b = find_root(b);

        if (a == b)
        {
            return;
        }

        if (ranks[a] < ranks[b])
        {
            parents[a] = b;
        }
        else if (ranks[a] > ranks[b])
        {
            parents[b] = a;
        }
        else
        {
            parents[b] = a;
            ranks[a]++;
        }

        root_count--;
    };
    auto are_linked(size_t a, size_t b) const -> bool
    {
        return find_root(a) == find_root(b);
    };
    auto count() const -> size_t
    {
        return root_count;
    };

  private:
    auto find_root(size_t i) const -> size_t
    {
        assert(i < parents.size());
        while (parents[i] != i)
        {
            i = parents[i] = parents[parents[i]]; // Path halving
        }
        return i;
    }
};

DisjointSetsSpeciesCounter::DisjointSetsSpeciesCounter(std::unique_ptr<genetics::ISimilarity> similarity)
: similarity(std::move(similarity))
{}

auto DisjointSetsSpeciesCounter::count_species(
                                               const model::Population &population) const -> size_t
{
    DisjointSets sets(population.size());
    for (size_t i = 0; i < population.size(); i++)
    {
        for (size_t j = i + 1; j < population.size(); j++)
        {
            if (similarity->compatible(population[i], population[j]))
            {
                sets.link(i, j);
            }
        }
    }
    return sets.count();
}

} // namespace fatint::measurement
