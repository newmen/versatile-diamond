#ifndef DIMER_H
#define DIMER_H

#include "../../base_spec.h"
using namespace vd;

class Dimer : public ConcreteBaseSpec<2>
{
public:
    static void find(Atom *anchor);

    using ConcreteBaseSpec::ConcreteBaseSpec;

private:
    static void findChildren(Atom *anchor);
};

#endif // DIMER_H
