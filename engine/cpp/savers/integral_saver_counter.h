#ifndef INTEGRALSAVERCOUNTER_H
#define INTEGRALSAVERCOUNTER_H

#include "counter_whith_saver.h"
#include "crystal_slice_saver.h"
#include "../phases/crystal.h"

namespace vd {

class IntegralSaverCounter : public CounterWhithSaver<CrystalSliceSaver>
{
    const char *_name;
    uint _sliceMaxNum;
    std::initializer_list<ushort> _targetTypes;

public:
    IntegralSaverCounter(double step, CrystalSliceSaver *csSaver);

    void save(const SavingData &sd) override;
};

}

#endif // INTEGRALSAVERCOUNTER_H
