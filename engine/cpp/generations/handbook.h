#ifndef HANDBOOK_H
#define HANDBOOK_H

#include <omp.h>
#include "../tools/common.h"
#include "../tools/scavenger.h"
#include "../phases/amorph.h"
#include "../species/keeper.h"
#include "../mc/mc.h"

#include "finder.h"
#include "names.h"
#include "crystals/diamond.h"

class Handbook
{
private:
    typedef Keeper<KeeperSpecNums> DKeeper;
    typedef Scavenger<BaseSpecNums, ScavengerReactionNums> DScavenger;
    typedef MC<TypicalReactionNums, UbiquitousReactionNums> DMC;

public:
    static Amorph amorph;

    static DKeeper keeper;
    static DScavenger scavenger;
    static DMC mc;

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
