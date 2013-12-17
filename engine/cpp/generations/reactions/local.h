#ifndef LOCAL_H
#define LOCAL_H

#include "../../atoms/atom.h"
using namespace vd;

#include "ubiquitous.h"

template <template <ushort> class B, class U, ushort RT, class S, ushort AT>
class Local : public B<RT>
{
    typedef B<RT> ParentType;

public:
    typedef U UbiquitousType;

    static typename ParentType::DepFindResult check(Atom *anchor);

protected:
    Local(Atom *target) : ParentType(target) {}
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <template <ushort> class B, class U, ushort RT, class S, ushort AT>
typename Local<B, U, RT, S, AT>::ParentType::DepFindResult Local<B, U, RT, S, AT>::check(Atom *anchor)
{
    bool stored = Handbook::mc().check(ParentType::MC_INDEX, anchor);

    if (anchor->is(AT) && anchor->hasRole<S>(AT))
    {
        return stored ?
                    ParentType::DepFindResult::FOUND :
                    ParentType::DepFindResult::NEW;
    }

    if (stored && anchor->prevIs(AT))
    {
        return ParentType::DepFindResult::REMOVED;
    }

    return ParentType::DepFindResult::NOT_FOUND;
}

#endif // LOCAL_H
