#ifndef HANDBOOK_H
#define HANDBOOK_H

#include <omp.h>
#include "../tools/common.h"
#include "../species/keeper.h"
#include "../mc/mc.h"

#include "finder.h"
#include "names.h"
#include "crystals/diamond.h"

class Handbook
{
    // TODO: to be need to store number of species that need for start finding of association reactions
    typedef Keeper<10> DKeeper;
    typedef MC<14, 2> DMC;

    static DKeeper __keeper;
    static DMC __mc;

public:
    static DKeeper &keeper();
    static DMC &mc();

    // atoms
private:

    static const ushort __atomsNum;
    static const bool __atomsAccordance[];

    static const ushort __atomsSpecifing[];

public:
    static bool atomIs(ushort complexType, ushort typeOf);
    static ushort specificate(ushort type);
};

#endif // HANDBOOK_H
