#ifndef LOCAL_H
#define LOCAL_H

#include <atoms/atom.h>
using namespace vd;

#include "../handbook.h"

template <template <ushort> class B, class U, ushort RT, ushort ST, ushort AT>
class Local : public B<RT>
{
    typedef B<RT> ParentType;

public:
    typedef U UbiquitousType;

    static typename ParentType::DepFindResult check(Atom *anchor);

protected:
    Local(Atom *target) : ParentType(target) {}

    template <class R> static void concretize(Atom *anchor);
    template <class R> static void unconcretize(Atom *anchor);
};

//////////////////////////////////////////////////////////////////////////////////////

template <template <ushort> class B, class U, ushort RT, ushort ST, ushort AT>
typename Local<B, U, RT, ST, AT>::ParentType::DepFindResult Local<B, U, RT, ST, AT>::check(Atom *anchor)
{
    bool stored = Handbook::mc().check(ParentType::MC_INDEX, anchor);

    if (anchor->is(AT) && anchor->hasRole(ST, AT))
    {
        return stored ?
                    ParentType::DepFindResult::FOUND :
                    ParentType::DepFindResult::NEW;
    }
    else
    {
        return stored ?
                    ParentType::DepFindResult::REMOVED :
                    ParentType::DepFindResult::NOT_FOUND;
    }
}

template <template <ushort> class B, class U, ushort RT, ushort ST, ushort AT>
template <class R>
void Local<B, U, RT, ST, AT>::concretize(Atom *anchor)
{
    static_assert(std::is_same<typename R::UbiquitousType, U>::value, "Undefined using reaction type");

    assert(anchor->isVisited());
    assert(anchor->is(AT));
    assert(anchor->hasRole(ST, AT));

    R::template replace<U, R>(anchor);
}

template <template <ushort> class B, class U, ushort RT, ushort ST, ushort AT>
template <class R>
void Local<B, U, RT, ST, AT>::unconcretize(Atom *anchor)
{
    static_assert(std::is_same<typename R::UbiquitousType, U>::value, "Undefined using reaction type");

    assert(anchor->isVisited());
    if (anchor->type() == NO_VALUE)
    {
        R::template removeAll<R>(anchor);
    }
    else
    {
        assert(anchor->is(AT));
        assert(!anchor->hasRole(ST, AT));

        R::template replace<R, U>(anchor);
    }
}

#endif // LOCAL_H
