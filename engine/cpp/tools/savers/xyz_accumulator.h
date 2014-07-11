#ifndef XYZ_ACCUMULATOR_H
#define XYZ_ACCUMULATOR_H

#include <ostream>
#include <unordered_map>
#include "accumulator.h"
#include "volume_atom.h"

namespace vd
{

class XYZAccumulator : public Accumulator
{
    typedef std::unordered_map<const Atom *, VolumeAtom> Atoms;
    Atoms _atoms;

public:
    explicit XYZAccumulator(const Detector *detector) : Accumulator(detector) {}

    const Atoms &atoms() const { return _atoms; }
    uint atomsNum() const { return _atoms.size(); }

protected:
    void treatHidden(const Atom *first, const Atom *second) override;
    void pushPair(const Atom *first, const Atom *second) override;

private:
    void storeAtom(const Atom *atom);
};

}

#endif // XYZ_ACCUMULATOR_H
