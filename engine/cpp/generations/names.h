#ifndef NAMES_H
#define NAMES_H

#include "../tools/common.h"

const ushort BaseSpecNums = 13;
enum BaseSpecNames : ushort
{
    BRIDGE,
    DIMER,
    METHYL_ON_DIMER,
    METHYL_ON_BRIDGE,

    BRIDGE_CTsi,
    BRIDGE_CRs,
    DIMER_CRi_CLi,
    DIMER_CRs,
    METHYL_ON_DIMER_CMu,
    METHYL_ON_DIMER_CMsu,
    METHYL_ON_DIMER_CLs_CMu,
    METHYL_ON_BRIDGE_CBi_CMu,
    HIGH_BRIDGE
};

const ushort KeeperSpecNums = 3;
enum KeeperSpecNames : ushort
{
    KEE_BRIDGE_CTsi,
    KEE_BRIDGE_CRs,
    KEE_HIGH_BRIDGE
};

const ushort UbiquitousReactionNums = 2;
enum UbiquitousReactionNames : ushort
{
    SURFACE_ACTIVATION,
    SURFACE_DEACTIVATION
};

const ushort TypicalReactionNums = 9;
enum TypicalReactionNames : ushort
{
    DIMER_FORMATION,
    DIMER_DROP,
    ADS_METHYL_TO_DIMER,
    METHYL_ON_DIMER_HYDROGEN_MIGRATION,
    METHYL_TO_HIGH_BRIDGE,
    HIGH_BRIDGE_STAND_TO_ONE_BRIDGE,
    DES_METHYL_FROM_BRIDGE,
    NEXT_LEVEL_BRIDGE_TO_HIGH_BRIDGE,
    HIGH_BRIDGE_STAND_TO_TWO_BRIDGES
};

const ushort ScavengerReactionNums = 3;
enum ScavengerReactionNames : ushort
{
    SCA_DIMER_FORMATION,
    SCA_HIGH_BRIDGE_STAND_TO_ONE_BRIDGE,
    SCA_HIGH_BRIDGE_STAND_TO_TWO_BRIDGES
};

#endif // NAMES_H
