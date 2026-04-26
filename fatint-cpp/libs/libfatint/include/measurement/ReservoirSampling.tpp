namespace fatint::measurement
{

template <typename T> ReservoirSampling<T>::ReservoirSampling() : current(std::nullopt)
{
}

template <typename T> ReservoirSampling<T>::~ReservoirSampling() = default;

template <typename T> void ReservoirSampling<T>::add(math::Random &random, T t)
{
    n++;
    if (random.chance(1.0 / static_cast<double>(n)))
    {
        current = std::optional<T>(t);
    }
}

template <typename T> auto ReservoirSampling<T>::get() -> std::optional<T>
{
    return current;
}

template <typename T> void ReservoirSampling<T>::reset()
{
    n = 0;
    current = std::nullopt;
}

} // namespace fatint::measurement
