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

#ifdef NEYRON
    template <class L> void each(const L &lambda)
    {
        for (uint i = 0; i < NUM; ++i)
        {
            lambda(this->item(i));
        }
    }
#endif // NEYRON
};

}

#endif // NEIGHBOURS_H
