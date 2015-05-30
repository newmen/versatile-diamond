#ifndef PROGRESSSAVERCOUNTER_H
#define PROGRESSSAVERCOUNTER_H

#include "saver_counter.h"
#include "progress_saver.h"

namespace vd
{

template <class HB>
class ProgressSaverCounter : public SaverCounter
{
    const ProgressSaver<HB> *_prgrsSaver;

public:
    ProgressSaverCounter(double step, const ProgressSaver<HB> *prgrsSaver) : SaverCounter(step), _prgrsSaver(prgrsSaver) {}

    void save(const SavingData &sd) override;
};

//////////////////////////////////////////////////////////////////////////////

template <class HB>
void ProgressSaverCounter<HB>::save(const SavingData &sd)
{
    _prgrsSaver->printShortState(sd.crystal, sd.amorph, sd.allTime, sd.currentTime);
}

}

#endif // PROGRESSSAVERCOUNTER_H
