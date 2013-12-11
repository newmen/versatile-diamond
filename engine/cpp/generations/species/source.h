#ifndef SOURCE_H
#define SOURCE_H

#include "../../species/source_spec.h"
using namespace vd;

#include "parent.h"

template <ushort ST, ushort USED_ATOMS_NUM>
class Source : public Parent<SourceSpec<USED_ATOMS_NUM>, ST>
{
    typedef Parent<SourceSpec<USED_ATOMS_NUM>, ST> ParentType;

protected:
    template <class... Args>
    Source(Args... args) : ParentType(args...) {}
};

#endif // SOURCE_H
