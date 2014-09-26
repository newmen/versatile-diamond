#ifndef TYPED_REACTION_H
#define TYPED_REACTION_H

#include <atoms/atom.h>
#include <tools/typed.h>
using namespace vd;

#include "../localizators/study_unit.h"
#include "../handbook.h"
#include "rates_reader.h"

template <class B, ushort RT>
class TypedReaction : public Typed<B, RT>, public RatesReader
{
    typedef Typed<B, RT> ParentType;

protected:
    template <class... Args> TypedReaction(Args... args) : ParentType(args...) {}

#ifdef NEYRON
    void analyzeAndChangeAtoms(Atom **atoms, ushort n) override;

private:
    StudyUnit **analyzeBefore(Atom **atoms, ushort n);
    void analyzeAfter(StudyUnit **units, Atom **atoms, ushort n);
#endif // NEYRON
};

#ifdef NEYRON
template <class B, ushort RT>
void TypedReaction<B, RT>::analyzeAndChangeAtoms(Atom **atoms, ushort n)
{
    StudyUnit **units = analyzeBefore(atoms, n);
    this->changeAtoms(atoms);
    analyzeAfter(units, atoms, n);
}

template <class B, ushort RT>
StudyUnit **TypedReaction<B, RT>::analyzeBefore(Atom **atoms, ushort n)
{
    StudyUnit **units = new StudyUnit *[n];
    for (uint i = 0; i < n; ++i)
    {
        units[i] = new StudyUnit(RT, atoms[i]);
    }
    return units;
}

template <class B, ushort RT>
void TypedReaction<B, RT>::analyzeAfter(StudyUnit **units, Atom **atoms, ushort n)
{
    for (uint i = 0; i < n; ++i)
    {
        units[i]->storeEndState(atoms[i]);
    }

    Handbook::eachLocalizator([units, n](Localizator *localizator) {
        for (uint i = 0; i < n; ++i)
        {
            localizator->adsorb(units[i]);
        }
    });

    for (uint i = 0; i < n; ++i)
    {
        delete units[i];
    }
}
#endif // NEYRON

#endif // TYPED_REACTION_H
