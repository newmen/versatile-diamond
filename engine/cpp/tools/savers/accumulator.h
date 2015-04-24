#ifndef ACCUMULATOR_H
#define ACCUMULATOR_H

#include <ostream>
#include <unordered_map>
#include "atom_info.h"
#include "bond_info.h"
#include "../../atoms/saving_atom.h"

namespace vd
{

class Accumulator
{
    const Detector *_detector;

public:
    const Detector *detector() const { return _detector; }

    void addBondedPair(const SavingAtom *from, const SavingAtom *to);

protected:
    Accumulator(const Detector *detector) : _detector(detector) {}
    virtual ~Accumulator() {}

    virtual void treatHidden(const SavingAtom *first, const SavingAtom *second) = 0;
    virtual void pushPair(const SavingAtom *first, const SavingAtom *second) = 0;
};

}

#endif // ACCUMULATOR_H
