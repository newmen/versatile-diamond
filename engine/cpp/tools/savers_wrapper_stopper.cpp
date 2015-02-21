#include "savers_wrapper_stopper.h"

namespace vd {

void SaversWrapperStopper::copyData()
{
    if (!_isDataCopied)
    {
        _amorph = new Amorph(*_amorph);
        _crystal = new Crystal(*_crystal);
    }
}

void SaversWrapperStopper::saveData() {}

Amorph *SaversWrapperStopper::amorph()
{
    return _amorph;
}

Crystal *SaversWrapperStopper::crystal()
{
    return _crystal;
}

SaversWrapperStopper::~SaversWrapperStopper()
{
    if (_isDataCopied)
    {
        delete _amorph;
        delete _crystal;
    }
}

}
