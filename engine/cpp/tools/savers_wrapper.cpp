#include "savers_wrapper.h"

namespace vd {

SaversWrapper::SaversWrapper(SaversDecorator *targ) { _target = targ; }

Amorph *SaversWrapper::amorph()
{
    return _target->amorph();
}

Crystal *SaversWrapper::crystal()
{
    return _target->crystal();
}

SaversWrapper::~SaversWrapper()
{

}

}
