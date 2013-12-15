#ifndef SPECIFIC_H
#define SPECIFIC_H

#include "base.h"

template <class B, ushort ST, ushort USED_ATOMS_NUM>
class Specific : public Base<SpecClassBuilder<B, SpecificSpec>, ST, USED_ATOMS_NUM>
{
    typedef Base<SpecClassBuilder<B, SpecificSpec>, ST, USED_ATOMS_NUM> ParentType;

public:
    template <class... Args>
    Specific(Args... args) : ParentType(args...) {}

protected:
    void keepFirstTime() override;
};

template <class B, ushort ST, ushort USED_ATOMS_NUM>
void Specific<B, ST, USED_ATOMS_NUM>::keepFirstTime()
{
    Handbook::specificKeeper().store(this);
}

#endif // SPECIFIC_H
