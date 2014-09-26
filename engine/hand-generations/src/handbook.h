#ifndef HANDBOOK_H
#define HANDBOOK_H

#include <mc/mc.h>
#include <tools/common.h>
#include <tools/scavenger.h>
#include <species/keeper.h>
#include <species/lateral_spec.h>
#include <species/specific_spec.h>
using namespace vd;

#include "env.h"
#include "finder.h"
#include "names.h"
#include "phases/diamond.h"
#include "phases/phase_boundary.h"
#include "atoms/atom.h"

#ifdef NEYRON
#include "localizators/localizators_pack.h"
#endif // NEYRON

class Handbook
{
    typedef MC<ALL_SPEC_REACTIONS_NUM, UBIQUITOUS_REACTIONS_NUM> DMC;

    typedef Keeper<LateralSpec, &LateralSpec::findLateralReactions> LKeeper;
    typedef Keeper<SpecificSpec, &SpecificSpec::findTypicalReactions> SKeeper;

    static DMC __mc;
    static PhaseBoundary __amorph;

    static LKeeper __lateralKeeper;
    static SKeeper __specificKeeper;
    static Scavenger __scavenger;

public:
    ~Handbook();

    static DMC &mc();

    static PhaseBoundary &amorph();

    static SKeeper &specificKeeper();
    static LKeeper &lateralKeeper();

    static Scavenger &scavenger();

    static bool isRegular(const Atom *atom);

    static ushort activesFor(const Atom *atom);
    static ushort hydrogensFor(const Atom *atom);
    static ushort hToActivesFor(const Atom *atom);
    static ushort activesToHFor(const Atom *atom);

private:
    static const bool __atomsAccordance[];
    static const ushort __atomsSpecifing[];

    static const ushort __regularAtomsTypes[];
    static const ushort __regularAtomsNum;

    static const ushort __hToActives[];
    static const ushort __activesToH[];

#ifdef NEYRON
    static LocalizatorsPack __localizators;
public:
    static void addLocalizator(Localizator *localizator);
    template <class L> static void eachLocalizator(const L &lambda);

    static const ushort __atomsClusterSize;
    static const ushort __tailStatesNum;
    static const ushort __tailStates[];
#endif // NEYRON

public:
    static const ushort __atomsNum;

    static const ushort __hOnAtoms[];
    static const ushort __activesOnAtoms[];

    static bool atomIs(ushort complexType, ushort typeOf);
    static ushort specificate(ushort type);

    typedef Diamond SurfaceCrystal;
};

#ifdef NEYRON
template <class L>
void Handbook::eachLocalizator(const L &lambda)
{
    __localizators.each(lambda);
}
#endif // NEYRON


#endif // HANDBOOK_H
