#ifndef NAMES_H
#define NAMES_H

#include "../tools/common.h"

enum BaseSpecNames : ushort
{
    BRIDGE,
    DIMER,
    BRIDGE_CTsi,
    DIMER_CRi_CLi
};

enum KeeperSpecNames : ushort
{
    KEE_BRIDGE_CTsi
};

enum UbiquitousReactionNames : ushort
{
    SURFACE_ACTIVATION,
    SURFACE_DEACTIVATION
};

enum TypicalReactionNames : ushort
{
    DIMER_FORMATION,
    DIMER_DROP
};

#endif // NAMES_H
