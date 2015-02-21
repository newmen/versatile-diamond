#ifndef SAVERSWRAPPER_H
#define SAVERSWRAPPER_H

#include "savers_decorator.h"

namespace vd {

class SaversWrapper
{
    SaversDecorator* _target;
public:
    SaversWrapper(SaversDecorator* targ);

    Amorph* amorph();
    Crystal* crystal();

    ~SaversWrapper();
};

}
#endif // SAVERSWRAPPER_H
