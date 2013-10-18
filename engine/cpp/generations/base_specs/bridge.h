#ifndef BRIDGE_H
#define BRIDGE_H

#include "../../base_spec.h"
using namespace vd;

class Bridge : public ConcreteBaseSpec<3>
{
public:
    static void find(Atom *anchor);

    using ConcreteBaseSpec::ConcreteBaseSpec;

private:
    static void findChildren(Atom *anchor);
};

#endif // BRIDGE_H
