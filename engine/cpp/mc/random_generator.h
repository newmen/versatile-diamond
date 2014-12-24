#ifndef RANDOM_GENERATOR_H
#define RANDOM_GENERATOR_H

#include <random>

namespace vd
{

class RandomGenerator
{
private:
    typedef std::mt19937_64 Generator;
    typedef std::uniform_real_distribution<double> Distribution;

    static Generator __initGenerator;
    static Distribution __initDistrib;

    Generator _generator;

public:
    static void init();

    RandomGenerator();

    double rand(double maxValue)
    {
        Distribution distribution(0.0, maxValue);
        return distribution(_generator);
    }

private:
    RandomGenerator(const RandomGenerator &) = delete;
    RandomGenerator(RandomGenerator &&) = delete;
    RandomGenerator &operator = (const RandomGenerator &) = delete;
    RandomGenerator &operator = (RandomGenerator &&) = delete;
};

}

#endif // RANDOM_GENERATOR_H
