#ifndef NAMES_H
#define NAMES_H

#include "../tools/common.h"

const ushort BaseSpecNums = 5;
enum BaseSpecNames : ushort
{
    BRIDGE,
    DIMER,
    BRIDGE_CTsi,
    DIMER_CRi_CLi,
    DIMER_CRs
};

const ushort KeeperSpecNums = 1;
enum KeeperSpecNames : ushort
{
    KEE_BRIDGE_CTsi
};

const ushort UbiquitousReactionNums = 2;
enum UbiquitousReactionNames : ushort
{
    SURFACE_ACTIVATION,
    SURFACE_DEACTIVATION
};

const ushort TypicalReactionNums = 3;
enum TypicalReactionNames : ushort
{
    DIMER_FORMATION,
    DIMER_DROP,
    METHYL_TO_DIMER
};

const ushort ScavengerReactionNums = 1;
enum ScavengerReactionNames : ushort
{
    SCA_DIMER_FORMATION
};

#endif // NAMES_H
