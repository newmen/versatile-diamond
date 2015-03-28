#ifndef INTEGRALSAVERBUILDER_H
#define INTEGRALSAVERBUILDER_H

#include "savers_builder.h"
#include "crystal_slice_saver.h"
#include "../phases/crystal.h"

namespace vd {

class IntegralSaverBuilder : public SaversBuilder
{
    const char *_name;
    uint _sliceMaxNum;
    std::initializer_list<ushort> _targetTypes;
    CrystalSliceSaver *csSaver;
public:
    IntegralSaverBuilder(const char *name,
                         uint sliceMaxNum,
                         std::initializer_list<ushort> targetTypes,
                         double step) :
        SaversBuilder(step),
        _name(name),
        _sliceMaxNum(sliceMaxNum),
        _targetTypes(targetTypes)
    {
        csSaver = new CrystalSliceSaver(_name, _sliceMaxNum, _targetTypes);
    }

    QueueItem* wrapItem(QueueItem* item);
    void save(const Amorph *amorph, const Crystal *crystal, double currentTime);
};

}

#endif // INTEGRALSAVERBUILDER_H
