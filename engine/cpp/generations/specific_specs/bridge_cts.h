#ifndef BRIDGE_CTS_H
#define BRIDGE_CTS_H

#include "../../base_spec.h"
using namespace vd;

class BridgeCts : public ConcreteBaseSpec<1>
{
public:
    static void find(Atom *anchor);

    using ConcreteBaseSpec::ConcreteBaseSpec;
};

#endif // BRIDGE_CTS_H
