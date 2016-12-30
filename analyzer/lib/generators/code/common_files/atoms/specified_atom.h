#ifndef SPECIFIED_ATOM_H
#define SPECIFIED_ATOM_H

#include <atoms/atom.h>
using namespace vd;

#include "../handbook.h"

template <ushort VALENCE>
class SpecifiedAtom : public Atom
{
public:
    SpecifiedAtom(ushort type, ushort actives, Atom::OriginalLattice *lattice) :
        Atom(type, actives, lattice) {}

    bool is(ushort typeOf) const final;
    bool prevIs(ushort typeOf) const final;

    void specifyType() final;

    ushort valence() const final { return VALENCE; }
    ushort hCount() const final;
#ifndef NDEBUG
    ushort actives() const final;
#endif // NDEBUG
};

//////////////////////////////////////////////////////////////////////////////////////

template <ushort VALENCE>
bool SpecifiedAtom<VALENCE>::is(ushort typeOf) const
{
    return type() != NO_VALUE && Handbook::atomIs(type(), typeOf);
}

template <ushort VALENCE>
bool SpecifiedAtom<VALENCE>::prevIs(ushort typeOf) const
{
    return prevType() != NO_VALUE && Handbook::atomIs(prevType(), typeOf);
}

template <ushort VALENCE>
void SpecifiedAtom<VALENCE>::specifyType()
{
    Atom::setType(Handbook::specificate(type()));
}

template <ushort VALENCE>
ushort SpecifiedAtom<VALENCE>::hCount() const
{
#if defined(PRINT) || defined(ATOM_PRINT)
    if (type() == NO_VALUE)
    {
        return 0;
    }
    else
    {
#else // PRINT || ATOM_PRINT
#ifndef NDEBUG
        Atom::hCount();
#endif // NDEBUG
#endif // PRINT || ATOM_PRINT
        return Handbook::hydrogensFor(type());
#if defined(PRINT) || defined(ATOM_PRINT)
    }
#endif // PRINT || ATOM_PRINT
}

#ifndef NDEBUG
template <ushort VALENCE>
ushort SpecifiedAtom<VALENCE>::actives() const
{
#if defined(PRINT) || defined(ATOM_PRINT)
    if (type() == NO_VALUE)
    {
        return 0;
    }
    else
    {
#endif // PRINT || ATOM_PRINT
        ushort result = Handbook::activesFor(type());
#if defined(PRINT) || defined(ATOM_PRINT)
        if (Atom::actives() != result)
        {
            debugPrint([&](IndentStream &os) {
                os << "...\n"
                   << "DANGER!! [" << (Atom *)this << "] "
                   << Atom::actives() << " != " << result
                   << "\n...";
            });
        }
#else // PRINT || ATOM_PRINT
        assert(Atom::actives() == result);
#endif // PRINT || ATOM_PRINT
        return result;
#if defined(PRINT) || defined(ATOM_PRINT)
    }
#endif // PRINT || ATOM_PRINT
}
#endif // NDEBUG

#endif // SPECIFIED_ATOM_H
