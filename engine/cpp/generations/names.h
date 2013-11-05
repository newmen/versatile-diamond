#ifndef NAMES_H
#define NAMES_H

#include "../tools/common.h"

const ushort BaseSpecNums = 12;
enum BaseSpecNames : ushort
{
    BRIDGE,
    DIMER,
    METHYL_ON_DIMER,
    METHYL_ON_BRIDGE,

    BRIDGE_CTsi,
    DIMER_CRi_CLi,
    DIMER_CRs,
    METHYL_ON_DIMER_CMu,
    METHYL_ON_DIMER_CMsu,
    METHYL_ON_DIMER_CLs_CMu,
    METHYL_ON_BRIDGE_CBi_CMu,
    HIGH_BRIDGE
};

const ushort KeeperSpecNums = 2;
enum KeeperSpecNames : ushort
{
    KEE_BRIDGE_CTsi,
    KEE_HIGH_BRIDGE
};

const ushort UbiquitousReactionNums = 2;
enum UbiquitousReactionNames : ushort
{
    SURFACE_ACTIVATION,
    SURFACE_DEACTIVATION
};

const ushort TypicalReactionNums = 7;
enum TypicalReactionNames : ushort
{
    DIMER_FORMATION,
    DIMER_DROP,
    ADS_METHYL_TO_DIMER,
    METHYL_ON_DIMER_HYDROGEN_MIGRATION,
    METHYL_TO_HIGH_BRIDGE,
    HIGH_BRIDGE_STAND_TO_ONE_BRIDGE,
    DES_METHYL_FROM_BRIDGE
};

const ushort ScavengerReactionNums = 2;
enum ScavengerReactionNames : ushort
{
    SCA_DIMER_FORMATION,
    SCA_HIGH_BRIDGE_STAND_TO_ONE_BRIDGE
};

#endif // NAMES_H
