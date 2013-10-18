#ifndef BRIDGE_CTS_H
#define BRIDGE_CTS_H

#include "../../specific_spec.h"
using namespace vd;

class BridgeCts : public SpecificSpec<1>
{
public:
    static void find(BaseSpec *parent);

    using SpecificSpec::SpecificSpec;

//private:
//    static void findChildren(Atom *anchor);
};

#endif // BRIDGE_CTS_H
