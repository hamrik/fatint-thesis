#include "measurement/DepthFirstSearchSpeciesCounter.hpp"
#include "genetics/genetics.hpp"
#include "model/types.hpp"
#include <memory>
#include <stack>

namespace fatint::measurement
{

DepthFirstSearchSpeciesCounter::DepthFirstSearchSpeciesCounter(std::unique_ptr<genetics::ISimilarity> similarity)
    : similarity(std::move(similarity))
{
}

auto DepthFirstSearchSpeciesCounter::count_species(const model::Population &population) const -> size_t
{
    if (population.empty())
    {
        return 0;
    }

    size_t count = 0;
    std::vector<bool> visited;
    visited.resize(population.size(), false);

    std::stack<size_t> st;
    st.push(0);
    visited[0] = true;

    for (; !st.empty(); count++)
    {
        while (!st.empty())
        {
            auto curr = st.top();
            st.pop();
            auto &a = population[curr];

            for (size_t i = 0; i < population.size(); i++)
            {
                if (visited[i])
                {
                    continue;
                }
                auto &b = population[i];
                if (similarity->compatible(a, b))
                {
                    st.push(i);
                    visited[i] = true;
                }
            }
        }
        for (size_t i = 0; i < population.size(); i++)
        {
            if (!visited[i])
            {
                st.push(i);
                break;
            }
        }
    }

    return count;
}

} // namespace fatint::measurement
