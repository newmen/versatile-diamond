#ifndef UBIQUITOUS_H
#define UBIQUITOUS_H

#include "../../reactions/ubiquitous_reaction.h"
#include "../../tools/typed.h"
using namespace vd;

#include "../finder.h"
#include "../handbook.h"

template <ushort RT>
class Ubiquitous : public Typed<UbiquitousReaction, RT>
{
    typedef Typed<UbiquitousReaction, RT> ParentType;

public:
    void doIt() override;

protected:
    enum : ushort { MC_INDEX = RT - SURFACE_ACTIVATION }; // must used first ID of ubiquitous reactions names

    enum DepFindResult : ushort // only if has Local reaction
    {
        NEW,
        FOUND,
        NOT_FOUND,
        REMOVED
    };

    Ubiquitous(Atom *target) : ParentType(target) {}

    template <class R>
    static void findSelf(Atom *anchor);

    template <class R>
    static void findChild(Atom *anchor);

private:
    template <class R>
    static void store(Atom *anchor, short delta);

    template <class R>
    static void remove(Atom *anchor, short delta);
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <ushort RT>
template <class R>
void Ubiquitous<RT>::findSelf(Atom *anchor)
{
    short dn = ParentType::delta(anchor, R::nums());
    if (dn > 0)
    {
        store<R>(anchor, dn);
    }
    else if (dn < 0)
    {
        remove<R>(anchor, dn);
    }
}

template <ushort RT>
template <class R>
void Ubiquitous<RT>::findChild(Atom *anchor)
{
    auto result = R::check(anchor);
    switch (result)
    {
    case NEW:
        remove<typename R::UbiquitousType>(anchor, -ParentType::prevNum(anchor, R::nums()));
        store<R>(anchor, ParentType::currNum(anchor, R::nums()));
        break;

    case FOUND:
        findSelf<R>(anchor);
        break;

    case NOT_FOUND:
        findSelf<typename R::UbiquitousType>(anchor);
        break;

    case REMOVED:
        remove<R>(anchor, -ParentType::prevNum(anchor, R::nums()));
        store<typename R::UbiquitousType>(anchor, ParentType::currNum(anchor, R::nums()));
        break;
    }
}

template <ushort RT>
template <class R>
void Ubiquitous<RT>::store(Atom *anchor, short delta)
{
    Handbook::mc().add(MC_INDEX, new R(anchor), delta);
}

template <ushort RT>
template <class R>
void Ubiquitous<RT>::remove(Atom *anchor, short delta)
{
    R removableTemplate(anchor);
    Handbook::mc().remove(MC_INDEX, &removableTemplate, -delta);
}

template <ushort RT>
void Ubiquitous<RT>::doIt()
{
    ParentType::doIt();

    Atom *atom[1] = { this->target() };
    Finder::findAll(atom, 1);
}

#endif // UBIQUITOUS_H
