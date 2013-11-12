#ifndef SOURCE_H
#define SOURCE_H

#include "../../species/source_spec.h"
using namespace vd;

#include "base.h"

template <ushort ST, ushort USED_ATOMS_NUM>
class Source : public Base<SourceSpec<USED_ATOMS_NUM>, ST, USED_ATOMS_NUM>
{
protected:
//    using Base<SourceSpec<USED_ATOMS_NUM>, ST, USED_ATOMS_NUM>::Base;
    template <class... Args>
    Source(Args... args) : Base<SourceSpec<USED_ATOMS_NUM>, ST, USED_ATOMS_NUM>(args...) {}
};

#endif // SOURCE_H
