#ifndef NAMES_H
#define NAMES_H

#include "../tools/common.h"

const ushort BaseSpecNums = 8;
enum BaseSpecNames : ushort
{
    BRIDGE,
    DIMER,
    METHYL_ON_DIMER,

    BRIDGE_CTsi,
    DIMER_CRi_CLi,
    DIMER_CRs,
    METHYL_ON_DIMER_CLs,
    METHYL_ON_DIMER_CMs
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

const ushort TypicalReactionNums = 5;
enum TypicalReactionNames : ushort
{
    DIMER_FORMATION,
    DIMER_DROP,
    ADS_METHYL_TO_DIMER,
    METHYL_ON_DIMER_HYDROGEN_MIGRATION,
    METHYL_TO_HIGH_BRIDGE
};

const ushort ScavengerReactionNums = 1;
enum ScavengerReactionNames : ushort
{
    SCA_DIMER_FORMATION
};

#endif // NAMES_H
