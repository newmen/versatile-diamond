#ifndef NAMES_H
#define NAMES_H

#include "../tools/common.h"

enum : ushort
{
    BASE_SPECS_NUM = 7,
    SPECIFIC_SPECS_NUM = 21,

    UBIQUITOUS_REACTIONS_NUM = 4,
    TYPICAL_REACTIONS_NUM = 23,
    LATERAL_REACTIONS_NUM = 4,

//    ALL_SPECS_NUM = BASE_SPECS_NUM + SPECIFIC_SPECS_NUM,
    ALL_SPEC_REACTIONS_NUM = TYPICAL_REACTIONS_NUM + LATERAL_REACTIONS_NUM
};

enum BaseSpecNames : ushort
{
    BRIDGE,
    DIMER,
    SHIFTED_DIMER, // TODO: realy need for methyl on dimer?!
    METHYL_ON_DIMER,
    METHYL_ON_BRIDGE,
    TWO_BRIDGES,
    BRIDGE_WITH_DIMER
};

enum SpecificSpecNames : ushort
{
    BRIDGE_CTsi = BASE_SPECS_NUM,
    BRIDGE_CRs,
    BRIDGE_CRs_CTi_CLi,
    DIMER_CRi_CLi,
    DIMER_CRs,
    DIMER_CRs_CLi,
    METHYL_ON_DIMER_CMu,
    METHYL_ON_DIMER_CMsu,
    METHYL_ON_DIMER_CLs_CMu,
    METHYL_ON_BRIDGE_CBi_CMu,
    METHYL_ON_BRIDGE_CBi_CMsu,
    METHYL_ON_BRIDGE_CBi_CMssu,
    METHYL_ON_BRIDGE_CBs_CMsu,
    METHYL_ON_111_CMu,
    METHYL_ON_111_CMsu,
    METHYL_ON_111_CMssu,
    HIGH_BRIDGE,
    HIGH_BRIDGE_CMs,
    TWO_BRIDGES_CBRs,
    BRIDGE_WITH_DIMER_CDLi,
    BRIDGE_WITH_DIMER_CBTi_CBRs_CDLi
};

enum TypicalReactionNames : ushort
{
    DIMER_FORMATION,
    DIMER_FORMATION_NEAR_BRIDGE,
    DIMER_DROP,
    DIMER_DROP_NEAR_BRIDGE,
    ADS_METHYL_TO_DIMER,
    METHYL_ON_DIMER_HYDROGEN_MIGRATION,
    METHYL_TO_HIGH_BRIDGE,
    HIGH_BRIDGE_STAND_TO_ONE_BRIDGE,
    DES_METHYL_FROM_BRIDGE,
    DES_METHYL_FROM_111,
    NEXT_LEVEL_BRIDGE_TO_HIGH_BRIDGE,
    HIGH_BRIDGE_STAND_TO_TWO_BRIDGES,
    TWO_BRIDGES_TO_HIGH_BRIDGE,
    BRIDGE_WITH_DIMER_TO_HIGH_BRIDGE_AND_DIMER,
    HIGH_BRIDGE_STAND_TO_DIMER,
    HIGH_BRIDGE_TO_METHYL,
    MIGRATION_DOWN_AT_DIMER,
    MIGRATION_DOWN_IN_GAP,
    MIGRATION_DOWN_AT_DIMER_FROM_111,
    MIGRATION_DOWN_IN_GAP_FROM_111,
    MIGRATION_DOWN_AT_DIMER_FROM_HIGH_BRIDGE,
    MIGRATION_DOWN_IN_GAP_FROM_HIGH_BRIDGE,
    FORM_TWO_BOND
};

enum LateralReactionNames : ushort
{
    DIMER_FORMATION_AT_END = TYPICAL_REACTIONS_NUM,
    DIMER_FORMATION_IN_MIDDLE,
    DIMER_DROP_AT_END,
    DIMER_DROP_IN_MIDDLE
};

enum UbiquitousReactionNames : ushort
{
    SURFACE_ACTIVATION = ALL_SPEC_REACTIONS_NUM,
    SURFACE_DEACTIVATION,
    METHYL_ON_DIMER_ACTIVATION,
    METHYL_ON_DIMER_DEACTIVATION
};

#endif // NAMES_H
