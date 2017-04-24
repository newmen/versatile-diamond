#ifndef HANDBOOK_H
#define HANDBOOK_H

#include <atoms/atom.h>
#include <mc/dynamic_mc.h>
#include <tools/common.h>
#include <tools/scavenger.h>
#include <tools/steps_serializer.h>
#include <species/keeper.h>
#include <species/lateral_spec.h>
#include <species/specific_spec.h>
using namespace vd;

#include "env.h"
#include "finder.h"
#include "names.h"
#include "phases/diamond.h"
#include "phases/phase_boundary.h"

class Handbook
{
public:
    typedef PhaseBoundary SurfaceAmorph;
    typedef Diamond SurfaceCrystal;

private:
    typedef DynamicMC<ALL_SPEC_REACTIONS_NUM, UBIQUITOUS_REACTIONS_NUM> MC;

    typedef Keeper<LateralSpec, &LateralSpec::findLateralReactions> LKeeper;
    typedef Keeper<SpecificSpec, &SpecificSpec::findTypicalReactions> SKeeper;

    static MC __mc;
    static SurfaceAmorph __amorph;

    static LKeeper __lateralKeeper;
    static SKeeper __specificKeeper;
    static Scavenger __scavenger;

#ifdef SERIALIZE
    static StepsSerializer __serializer;
#endif // SERIALIZE

public:
    ~Handbook();

#ifdef SERIALIZE
    static StepsSerializer &serializer();
#endif // SERIALIZE
    static MC &mc();

    static SurfaceAmorph &amorph();

    static SKeeper &specificKeeper();
    static LKeeper &lateralKeeper();

    static Scavenger &scavenger();

    static bool isRegular(ushort type);

    static ushort activesFor(ushort type);
    static ushort hydrogensFor(ushort type);
    static ushort hToActivesFor(ushort type);
    static ushort activesToHFor(ushort type);

private:
    static const bool __atomsAccordance[];
    static const ushort __atomsSpecifing[];

    static const ushort __regularAtomsTypes[];
    static const ushort __regularAtomsNum;

    static const ushort __hToActives[];
    static const ushort __activesToH[];

public:
    static const ushort __atomsNum;

    static const ushort __hOnAtoms[];
    static const ushort __activesOnAtoms[];

    static bool atomIs(ushort complexType, ushort typeOf);
    static ushort specificate(ushort type);
};

#endif // HANDBOOK_H
