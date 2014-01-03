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

    template <class R> static void concretize(Atom *anchor);
    template <class R> static void unconcretize(Atom *anchor);
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

    if (stored && (anchor->is(AT) || anchor->prevIs(AT)))
    {
        return ParentType::DepFindResult::REMOVED;
    }

    return ParentType::DepFindResult::NOT_FOUND;
}

template <template <ushort> class B, class U, ushort RT, class S, ushort AT>
template <class R>
void Local<B, U, RT, S, AT>::concretize(Atom *anchor)
{
    static_assert(std::is_same<typename R::UbiquitousType, U>::value, "Undefined using reaction type");

    assert(anchor->isVisited());
    assert(anchor->is(AT));
    assert(anchor->hasRole<S>(AT));

    short n = ParentType::currNum(anchor, R::nums());
    ParentType::template remove<U>(anchor, -n);
    ParentType::template store<R>(anchor, n);
}

template <template <ushort> class B, class U, ushort RT, class S, ushort AT>
template <class R>
void Local<B, U, RT, S, AT>::unconcretize(Atom *anchor)
{
    static_assert(std::is_same<typename R::UbiquitousType, U>::value, "Undefined using reaction type");

    assert(anchor->isVisited());
    assert(anchor->is(AT));
    assert(!anchor->hasRole<S>(AT));

    short n = ParentType::currNum(anchor, R::nums());
    ParentType::template remove<R>(anchor, -n);
    ParentType::template store<U>(anchor, n);
}

#endif // LOCAL_H
