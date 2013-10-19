#ifndef BRIDGE_CTS_H
#define BRIDGE_CTS_H

#include "../../dependent_spec.h"
using namespace vd;

class BridgeCts : public DependentSpec<1>
{
public:
    static void find(BaseSpec *parent);

    using DependentSpec::DependentSpec;

    void findChildren();
};

#endif // BRIDGE_CTS_H
