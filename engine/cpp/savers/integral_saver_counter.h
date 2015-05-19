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
    IntegralSaverCounter(const char *name,
                         uint sliceMaxNum,
                         const std::initializer_list<ushort> &targetTypes,
                         double step) :
        SaverCounter(step),
        _name(name),
        _sliceMaxNum(sliceMaxNum),
        _targetTypes(targetTypes)
    {
        _csSaver = new CrystalSliceSaver(_name, _sliceMaxNum, _targetTypes);
    }

    void save(const SavingData &sd) override;
};

}

#endif // INTEGRALSAVERCOUNTER_H
