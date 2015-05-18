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

    void save(const SavingData &sd) override;
};

//////////////////////////////////////////////////////////////////////////////

template <class HB>
void ProgressSaverBuilder<HB>::save(const SavingData &sd)
{
    ProgressSaver<HB> *saver = new ProgressSaver<HB>();
    saver->printShortState(sd.crystal, sd.amorph, sd.allTime);
}

}

#endif // PROGRESSSAVERBUILDER_H
