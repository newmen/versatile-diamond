#ifndef NEIGHBOURS_H
#define NEIGHBOURS_H

#include "../tools/many_items_result.h"
#include "atom.h"

namespace vd
{

template <ushort NUM>
class Neighbours : public ManyItemsResult<Atom, NUM>
{
    typedef ManyItemsResult<Atom, NUM> ParentType;

public:
    template <class... Args> Neighbours(Args... args) : ParentType(args...) {}
};

}

#endif // NEIGHBOURS_H
