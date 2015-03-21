#ifndef INTEGRALSAVERBUILDER_H
#define INTEGRALSAVERBUILDER_H

#include "savers_builder.h"
#include "../phases/crystal.h"

namespace vd {

class IntegralSaverBuilder : public SaversBuilder
{
    const std::string _name;
    const uint _sliceMaxNum;
    double _currentTime;
    std::initializer_list<ushort> _targetTypes;

public:
    IntegralSaverBuilder(const char *name,
                         uint sliceMaxNum,
                         double currentTime,
                         std::initializer_list<ushort> targetTypes,
                         double step) :
        SaversBuilder(step),
        _name(name),
        _sliceMaxNum(sliceMaxNum),
        _currentTime(currentTime),
        _targetTypes(targetTypes) {}

    QueueItem* wrapItem(QueueItem* item);
    void save(Crystal *crystal);
};

}

#endif // INTEGRALSAVERBUILDER_H
