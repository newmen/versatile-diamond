#include "random_generator.h"
#include <chrono>

namespace vd
{

RandomGenerator::Generator RandomGenerator::__initGenerator;
RandomGenerator::Distribution RandomGenerator::__initDistrib;

void RandomGenerator::init()
{
    typedef std::chrono::high_resolution_clock Clock;

    Clock::duration distance = Clock::now().time_since_epoch();
    __initGenerator = Generator(distance.count());
    __initDistrib = Distribution(0, distance.count());
}

RandomGenerator::RandomGenerator()
{
    _generator.seed(__initDistrib(__initGenerator));
}

}
