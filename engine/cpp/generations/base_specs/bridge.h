#ifndef BRIDGE_H
#define BRIDGE_H

#include "../../base_spec.h"
using namespace vd;

class Bridge : public ConcreteBaseSpec<3>
{
public:
    using ConcreteBaseSpec::ConcreteBaseSpec;

//    void findChildren() override;
};

#endif // BRIDGE_H
