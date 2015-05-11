#ifndef PROGRESSSAVERBUILDER_H
#define PROGRESSSAVERBUILDER_H

#include "saver_builder.h"
#include "progress_saver.h"

namespace vd
{

template <class HB>
class ProgressSaverBuilder : public SaverBuilder
{
public:
    ProgressSaverBuilder(double step) : SaverBuilder(step) {}
    ~ProgressSaverBuilder() {}

    void save(const SavingAmorph *amorph, const SavingCrystal *crystal, const char *, double currentTime) override;
};

//////////////////////////////////////////////////////////////////////////////

template <class HB>
void ProgressSaverBuilder<HB>::save(const SavingAmorph *amorph, const SavingCrystal *crystal, const char *, double currentTime)
{
    ProgressSaver<HB> *saver = new ProgressSaver<HB>();
    saver->printShortState(crystal, amorph, currentTime);
}

}

#endif // PROGRESSSAVERBUILDER_H
