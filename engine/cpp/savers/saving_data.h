#ifndef SAVING_DATA
#define SAVING_DATA

#include "../phases/saving_amorph.h"
#include "../phases/saving_crystal.h"

namespace vd
{
    struct SavingData
    {
        const SavingAmorph *amorph;
        const SavingCrystal *crystal;
        double allTime;
        double currentTime;
        const char *name;
    };
}

#endif // SAVING_DATA

