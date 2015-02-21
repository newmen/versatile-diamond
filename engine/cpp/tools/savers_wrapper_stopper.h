#ifndef SAVERSWRAPPERSTOPPER_H
#define SAVERSWRAPPERSTOPPER_H

#include "savers_decorator.h"

namespace vd {

class SaversWrapperStopper
{
    Amorph* _amorph;
    Crystal* _crystal;
    bool _isDataCopied = false;

public:
    SaversWrapperStopper(Amorph* amorph, Crystal* crystal) : _amorph(amorph), _crystal(crystal) {}

    void copyData();
    void saveData();
    Amorph* amorph();
    Crystal* crystal();

    ~SaversWrapperStopper();
};

}

#endif // SAVERSWRAPPERSTOPPER_H
