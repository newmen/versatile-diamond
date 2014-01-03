#ifndef SHIFTED_DIMER_H
#define SHIFTED_DIMER_H

#include "../sidepiece/dimer.h"
#include "../empty_dependent.h"

// TODO: should not be!
class ShiftedDimer : public AtomShiftWrapper<EmptyDependent<ParentSpec, SHIFTED_DIMER, 1>>
{
public:
    ShiftedDimer(Dimer *parent) : AtomShiftWrapper(3, parent) {}

#ifdef PRINT
    const std::string name() const override { return "shifted dimer"; }
#endif // PRINT

protected:
    void findAllChildren() override {}
};

#endif // SHIFTED_DIMER_H
