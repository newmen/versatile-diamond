#ifndef CONTAINED_SPECIES_H
#define CONTAINED_SPECIES_H

#include "../tools/many_items_result.h"

namespace vd
{

// No different from ManyItemsResult
template <class S, ushort NUM>
class ContainedSpecies : public ManyItemsResult<S, NUM>
{
    typedef ManyItemsResult<S, NUM> ParentType;

public:
    template <class... Args> ContainedSpecies(Args... args) : ParentType(args...) {}
};

}

#endif // CONTAINED_SPECIES_H
