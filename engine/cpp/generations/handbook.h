#ifndef HANDBOOK_H
#define HANDBOOK_H

#include "../tools/common.h"
#include "../tools/scavenger.h"
#include "../species/keeper.h"
#include "../mc/mc.h"

#include "finder.h"
#include "names.h"
#include "crystals/diamond.h"
#include "crystals/phase_boundary.h"

class Handbook
{
private:
    typedef Keeper<SpecificSpecsNum> DKeeper;
    typedef Scavenger<(BaseSpecsNum + SpecificSpecsNum), TypicalReactionsNum> DScavenger;
    typedef MC<TypicalReactionsNum, UbiquitousReactionsNum> DMC;

    static PhaseBoundary __amorph;
    static DKeeper __keepers[THREADS_NUM];
    static DScavenger __scavengers[THREADS_NUM];
    static DMC __mc;

public:
    ~Handbook();

    static PhaseBoundary &amorph();
    static DKeeper &keeper();
    static DScavenger &scavenger();
    static DMC &mc();

    // atoms
    static const ushort atomsNum;

private:
    static const bool __atomsAccordance[];
    static const ushort __atomsSpecifing[];

public:
    static bool atomIs(ushort complexType, ushort typeOf);
    static ushort specificate(ushort type);
};

#endif // HANDBOOK_H
