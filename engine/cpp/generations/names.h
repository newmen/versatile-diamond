#ifndef NAMES_H
#define NAMES_H

#include "../tools/common.h"

const ushort BaseSpecsNum = 4;
enum BaseSpecNames : ushort
{
    BRIDGE,
    DIMER,
    METHYL_ON_DIMER,
    METHYL_ON_BRIDGE
};

const ushort SpecificSpecsNum = 10;
enum SpecificSpecNames : ushort
{
    BRIDGE_CTsi = BaseSpecsNum,
    BRIDGE_CRs,
    BRIDGE_CRs_CTi_CLi,
    DIMER_CRi_CLi,
    DIMER_CRs,
    METHYL_ON_DIMER_CMu,
    METHYL_ON_DIMER_CMsu,
    METHYL_ON_DIMER_CLs_CMu,
    METHYL_ON_BRIDGE_CBi_CMu,
    HIGH_BRIDGE
};

const ushort TypicalReactionsNum = 9;
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

const ushort UbiquitousReactionsNum = 2;
enum UbiquitousReactionNames : ushort
{
    SURFACE_ACTIVATION = TypicalReactionsNum,
    SURFACE_DEACTIVATION
};

#endif // NAMES_H
