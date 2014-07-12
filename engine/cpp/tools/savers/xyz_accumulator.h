#ifndef XYZ_ACCUMULATOR_H
#define XYZ_ACCUMULATOR_H

#include <ostream>
#include <unordered_set>
#include "accumulator.h"

namespace vd
{

class XYZAccumulator : public Accumulator
{
    typedef std::unordered_set<const Atom *> Atoms;
    Atoms _atoms;

public:
    explicit XYZAccumulator(const Detector *detector) : Accumulator(detector) {}

    const Atoms &atoms() const { return _atoms; }

protected:
    void treatHidden(const Atom *first, const Atom *second) override;
    void pushPair(const Atom *first, const Atom *second) override;
};

}

#endif // XYZ_ACCUMULATOR_H
