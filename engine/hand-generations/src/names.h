#ifndef NAMES_H
#define NAMES_H

#include <tools/common.h>

enum : ushort
{
    BASE_SPECS_NUM = 8,
    SPECIFIC_SPECS_NUM = 26,

    UBIQUITOUS_REACTIONS_NUM = 4,
    TYPICAL_REACTIONS_NUM = 30,
    LATERAL_REACTIONS_NUM = 4,

//    ALL_SPECS_NUM = BASE_SPECS_NUM + SPECIFIC_SPECS_NUM,
    ALL_SPEC_REACTIONS_NUM = TYPICAL_REACTIONS_NUM + LATERAL_REACTIONS_NUM
};

enum BaseSpecNames : ushort
{
    BRIDGE,
    DIMER,
    SYMMETRIC_BRIDGE,
    SYMMETRIC_DIMER,
    METHYL_ON_BRIDGE,
    METHYL_ON_DIMER,
    TWO_BRIDGES,
    BRIDGE_WITH_DIMER
};

static_assert(BRIDGE_WITH_DIMER + 1 == BASE_SPECS_NUM,
              "Incorrect number of base species");

enum SpecificSpecNames : ushort
{
    BRIDGE_CTsi = BASE_SPECS_NUM,
    BRIDGE_CRi,
    BRIDGE_CRh,
    BRIDGE_CRs,
    BRIDGE_CRs_CTi_CLi,
    SYMMETRIC_DIMER_CRi_CLi,
    DIMER_CRi_CLi,
    DIMER_CRs,
    DIMER_CRs_CLi,
    METHYL_ON_DIMER_CMiu,
    METHYL_ON_DIMER_CMsiu,
    METHYL_ON_DIMER_CMssiu,
    METHYL_ON_DIMER_CLs_CMhiu,
    METHYL_ON_BRIDGE_CBi_CMiu,
    METHYL_ON_BRIDGE_CBi_CMsiu,
    METHYL_ON_BRIDGE_CBi_CMssiu,
    METHYL_ON_BRIDGE_CBs_CMsiu,
    METHYL_ON_111_CMiu,
    METHYL_ON_111_CMsiu,
    METHYL_ON_111_CMssiu,
    HIGH_BRIDGE,
    HIGH_BRIDGE_CMs,
    TWO_BRIDGES_CTRi_CBRs,
    BRIDGE_WITH_DIMER_CDLi,
    BRIDGE_WITH_DIMER_CBTi_CBRs_CDLi,
    CROSS_BRIDGE_ON_BRIDGES
};

static_assert(CROSS_BRIDGE_ON_BRIDGES + 1 == SPECIFIC_SPECS_NUM + BASE_SPECS_NUM,
              "Incorrect number of specific species");

enum TypicalReactionNames : ushort
{
    DIMER_FORMATION,
    DIMER_FORMATION_NEAR_BRIDGE,
    DIMER_DROP,
    DIMER_DROP_NEAR_BRIDGE,
    ADS_METHYL_TO_DIMER,
    ADS_METHYL_TO_111,
    METHYL_ON_DIMER_HYDROGEN_MIGRATION,
    METHYL_TO_HIGH_BRIDGE,
    FORM_TWO_BOND,
    HIGH_BRIDGE_STAND_TO_ONE_BRIDGE,
    DES_METHYL_FROM_BRIDGE,
    DES_METHYL_FROM_111,
    DES_METHYL_FROM_DIMER,
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
    MIGRATION_DOWN_AT_DIMER_FROM_DIMER,
    MIGRATION_DOWN_IN_GAP_FROM_DIMER,
    ABS_HYDROGEN_FROM_GAP,
    MIGRATION_THROUGH_DIMERS_ROW,
    SIERPINSKI_DROP
};

static_assert(SIERPINSKI_DROP + 1 == TYPICAL_REACTIONS_NUM,
              "Incorrect number of typical reactions");

enum LateralReactionNames : ushort
{
    DIMER_FORMATION_AT_END = TYPICAL_REACTIONS_NUM,
    DIMER_FORMATION_IN_MIDDLE,
    DIMER_DROP_AT_END,
    DIMER_DROP_IN_MIDDLE
};

static_assert(DIMER_DROP_IN_MIDDLE + 1 == TYPICAL_REACTIONS_NUM + LATERAL_REACTIONS_NUM,
              "Incorrect number of lateral reactions");

enum UbiquitousReactionNames : ushort
{
    SURFACE_ACTIVATION = ALL_SPEC_REACTIONS_NUM,
    SURFACE_DEACTIVATION,
    METHYL_ON_DIMER_ACTIVATION,
    METHYL_ON_DIMER_DEACTIVATION
};

static_assert(METHYL_ON_DIMER_DEACTIVATION + 1 == TYPICAL_REACTIONS_NUM + LATERAL_REACTIONS_NUM + UBIQUITOUS_REACTIONS_NUM,
              "Incorrect number of ubiquitous reactions");

#endif // NAMES_H
