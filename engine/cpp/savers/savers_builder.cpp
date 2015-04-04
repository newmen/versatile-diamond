#include "savers_builder.h"

namespace vd {

bool SaversBuilder::isNeedSave(double diffTime)
{
    bool isNeedSave = false;
    _accTime += diffTime;
    if (_accTime >= _step)
    {
        isNeedSave = true;
        _accTime -= _step;
    }
    return isNeedSave;
}

}
