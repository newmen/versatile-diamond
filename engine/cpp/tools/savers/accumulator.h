#ifndef ACCUMULATOR_H
#define ACCUMULATOR_H

#include <ostream>
#include <unordered_map>
#include "atom_info.h"
#include "bond_info.h"
#include "../../atoms/atom.h"

namespace vd
{

class Accumulator
{
    const Detector *_detector;

public:
    const Detector *detector() const { return _detector; }
    void addBondedPair(const Atom *from, const Atom *to);

protected:
    Accumulator(const Detector *detector) : _detector(detector) {}

    virtual void treatHidden(const Atom *first, const Atom *second) = 0;
    virtual void pushPair(const Atom *first, const Atom *second) = 0;
};

}

#endif // ACCUMULATOR_H
