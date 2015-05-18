#ifndef XYZ_ACCUMULATOR_H
#define XYZ_ACCUMULATOR_H

#include <ostream>
#include <unordered_set>
#include "accumulator.h"

namespace vd
{

class XYZAccumulator : public Accumulator
{
    typedef std::unordered_set<const SavingAtom *> Atoms;
    Atoms _atoms;

public:
    explicit XYZAccumulator(const Detector *detector) : Accumulator(detector) {}

    const Atoms &atoms() const { return _atoms; }

protected:
    void treatHidden(const SavingAtom *first, const SavingAtom *second) override;
    void pushPair(const SavingAtom *first, const SavingAtom *second) override;

private:
    XYZAccumulator(const XYZAccumulator &) = delete;
    XYZAccumulator(XYZAccumulator &&) = delete;
    XYZAccumulator &operator = (const XYZAccumulator &) = delete;
    XYZAccumulator &operator = (XYZAccumulator &&) = delete;
};

}

#endif // XYZ_ACCUMULATOR_H
