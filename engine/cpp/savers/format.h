#ifndef FORMAT_H
#define FORMAT_H

#include <string>
#include <ctime>
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
    time_t rawtime;
    struct tm *timeinfo = nullptr;
    char buffer[80];

    time(&rawtime);
    timeinfo = localtime(&rawtime);

    strftime(buffer, 80, "%d-%m-%Y %H:%M:%S", timeinfo);
    return buffer;
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
