#ifndef INTEGRALSAVERBUILDER_H
#define INTEGRALSAVERBUILDER_H

#include "saver_builder.h"
#include "crystal_slice_saver.h"
#include "../phases/crystal.h"

namespace vd {

class IntegralSaverBuilder : public SaverBuilder
{
    const char *_name;
    uint _sliceMaxNum;
    std::initializer_list<ushort> _targetTypes;
    CrystalSliceSaver *_csSaver;
public:
    IntegralSaverBuilder(const char *name,
                         uint sliceMaxNum,
                         const std::initializer_list<ushort> &targetTypes,
                         double step) :
        SaverBuilder(step),
        _name(name),
        _sliceMaxNum(sliceMaxNum),
        _targetTypes(targetTypes)
    {
        _csSaver = new CrystalSliceSaver(_name, _sliceMaxNum, _targetTypes);
    }

    void save(const SavingData &sd) override;
};

}

#endif // INTEGRALSAVERBUILDER_H
