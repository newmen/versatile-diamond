#ifndef SIDEPIECE_H
#define SIDEPIECE_H

#include "base.h"

template <class B, ushort ST, ushort USED_ATOMS_NUM>
class Sidepiece : public Base<SpecClassBuilder<B, LateralSpec>, ST, USED_ATOMS_NUM>
{
    typedef Base<SpecClassBuilder<B, LateralSpec>, ST, USED_ATOMS_NUM> ParentType;

public:
    template <class... Args>
    Sidepiece(Args... args) : ParentType(args...) {}

protected:
    void keepFirstTime() override;
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class B, ushort ST, ushort USED_ATOMS_NUM>
void Sidepiece<B, ST, USED_ATOMS_NUM>::keepFirstTime()
{
    Handbook::lateralKeeper().store(this);
}

#endif // SIDEPIECE_H
