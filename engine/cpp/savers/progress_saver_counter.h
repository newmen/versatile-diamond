#ifndef PROGRESSSAVERCOUNTER_H
#define PROGRESSSAVERCOUNTER_H

#include "counter_whith_saver.h"
#include "progress_saver.h"

namespace vd
{

template <class HB>
class ProgressSaverCounter : public CounterWhithSaver<ProgressSaver<HB>>
{
public:
    template <class... Args>
    ProgressSaverCounter(Args... args) : CounterWhithSaver<ProgressSaver<HB>>(args...) {}

    void save(const SavingData &sd) override;
};

//////////////////////////////////////////////////////////////////////////////

template <class HB>
void ProgressSaverCounter<HB>::save(const SavingData &sd)
{
    CounterWhithSaver<ProgressSaver<HB>>::saver()->printShortState(sd.crystal, sd.amorph, sd.allTime, sd.currentTime);
}

}

#endif // PROGRESSSAVERCOUNTER_H
