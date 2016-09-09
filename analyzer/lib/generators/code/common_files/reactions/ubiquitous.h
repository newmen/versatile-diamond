#ifndef UBIQUITOUS_H
#define UBIQUITOUS_H

#include <reactions/ubiquitous_reaction.h>
#include <tools/typed.h>
using namespace vd;

#include "../finder.h"
#include "../handbook.h"
#include "rates_reader.h"

template <ushort RT>
class Ubiquitous : public Typed<UbiquitousReaction, RT>, public RatesReader
{
    typedef Typed<UbiquitousReaction, RT> ParentType;

public:
    // ubiquitous reaction enums should be enumerated after all another reaction enums
    enum : ushort { MC_INDEX = RT - ALL_SPEC_REACTIONS_NUM };

    void doIt() override;

protected:
    enum DepFindResult : ushort // only if has Local reaction
    {
        NEW,
        FOUND,
        NOT_FOUND,
        REMOVED
    };

    Ubiquitous(Atom *target) : ParentType(target) {}

    template <class R> static void findSelf(Atom *anchor);
    template <class R> static void findChild(Atom *anchor);

    template <class R> static void store(Atom *anchor, short delta);
    template <class R> static void remove(Atom *anchor, short delta);

private:
    template <class R> static void removeAll(Atom *anchor);
};

//////////////////////////////////////////////////////////////////////////////////////

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
        remove<R>(anchor, -dn);
    }
}

template <ushort RT>
template <class R>
void Ubiquitous<RT>::findChild(Atom *anchor)
{
    short n;
    auto result = R::check(anchor);
    switch (result)
    {
    case NEW:
        removeAll<typename R::UbiquitousType>(anchor);

        n = ParentType::currNum(anchor, R::nums());
        if (n > 0)
        {
            store<R>(anchor, n);
        }
        break;

    case FOUND:
        findSelf<R>(anchor);
        break;

    case NOT_FOUND:
        findSelf<typename R::UbiquitousType>(anchor);
        break;

    case REMOVED:
        removeAll<R>(anchor);

        n = ParentType::currNum(anchor, R::nums());
        if (n > 0)
        {
            store<typename R::UbiquitousType>(anchor, n);
        }
        break;
    }
}

template <ushort RT>
template <class R>
void Ubiquitous<RT>::store(Atom *anchor, short delta)
{
    Handbook::mc().add(R::MC_INDEX, new R(anchor), delta);
}

template <ushort RT>
template <class R>
void Ubiquitous<RT>::remove(Atom *anchor, short delta)
{
    R removableTemplate(anchor);
    Handbook::mc().remove(R::MC_INDEX, &removableTemplate, delta);
}

template <ushort RT>
template <class R>
void Ubiquitous<RT>::removeAll(Atom *anchor)
{
    R removableTemplate(anchor);
    Handbook::mc().removeAll(R::MC_INDEX, &removableTemplate);
}

template <ushort RT>
void Ubiquitous<RT>::doIt()
{
    ParentType::doIt();

    Atom *atom = this->target();
    Finder::findAll(&atom, 1);
}

#endif // UBIQUITOUS_H
