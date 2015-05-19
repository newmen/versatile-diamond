#ifndef PROGRESSSAVERCOUNTER_H
#define PROGRESSSAVERCOUNTER_H

#include "saver_counter.h"
#include "progress_saver.h"

namespace vd
{

template <class HB>
class ProgressSaverCounter : public SaverCounter
{
public:
    ProgressSaverCounter(double step) : SaverCounter(step) {}
    ~ProgressSaverCounter() {}

    void save(const SavingData &sd) override;
};

//////////////////////////////////////////////////////////////////////////////

template <class HB>
void ProgressSaverCounter<HB>::save(const SavingData &sd)
{
    ProgressSaver<HB> *saver = new ProgressSaver<HB>();
    saver->printShortState(sd.crystal, sd.amorph, sd.allTime, sd.currentTime);
}

}

#endif // PROGRESSSAVERCOUNTER_H
