#include "soul.h"

namespace vd {

void Soul::copyData()
{
    if (!_isDataCopied)
    {
        _amorph = new Amorph(*_amorph);
        _crystal = new Crystal(*_crystal);
    }
}

void Soul::saveData() {}

Amorph *Soul::amorph()
{
    return _amorph;
}

Crystal *Soul::crystal()
{
    return _crystal;
}

Soul::~Soul()
{
    if (_isDataCopied)
    {
        delete _amorph;
        delete _crystal;
    }
}

}
