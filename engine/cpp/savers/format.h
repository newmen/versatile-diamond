#ifndef FORMAT_H
#define FORMAT_H

#include <string>
#include <chrono>
#include "../phases/saving_reactor.h"

namespace vd
{

template <class Base, class Accumulator>
class Format : public Base
{
    const Accumulator *_accumulator = nullptr;

protected:
    template <class... Args> Format(Args... args) : Base(args...) {}

    static std::string timestamp();

    void save(const SavingReactor *reactor) override;
    const Accumulator *accumulator() const;
};

/////////////////////////////////////////////////////////////////////////////////////////

template <class B, class A>
std::string Format<B, A>::timestamp()
{
    std::chrono::time_point<std::chrono::system_clock> timePoint = std::chrono::system_clock::now();
    std::time_t convertedTime = std::chrono::system_clock::to_time_t(timePoint);
    return std::ctime(&convertedTime);
}

template <class B, class A>
void Format<B, A>::save(const SavingReactor *reactor)
{
    A accumulator(this->detector());
    reactor->eachAtom([&accumulator](const SavingAtom *atom) {
        atom->eachNeighbour([&accumulator, atom](SavingAtom *nbr) {
            accumulator.addBondedPair(atom, nbr);
        });
    });

    assert(!_accumulator);
    _accumulator = &accumulator;
    B::save(reactor);
    _accumulator = nullptr;
}

template <class B, class A>
const A *Format<B, A>::accumulator() const
{
    assert(_accumulator);
    return _accumulator;
}

}

#endif // FORMAT_H
