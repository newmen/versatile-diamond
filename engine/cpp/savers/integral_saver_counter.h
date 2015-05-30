#ifndef INTEGRALSAVERCOUNTER_H
#define INTEGRALSAVERCOUNTER_H

#include "saver_counter.h"
#include "crystal_slice_saver.h"
#include "../phases/crystal.h"

namespace vd {

class IntegralSaverCounter : public SaverCounter
{
    const char *_name;
    uint _sliceMaxNum;
    std::initializer_list<ushort> _targetTypes;
    CrystalSliceSaver *_csSaver;

public:
    IntegralSaverCounter(double step, CrystalSliceSaver *csSaver);

    void save(const SavingData &sd) override;
};

}

#endif // INTEGRALSAVERCOUNTER_H
