#ifndef DIMER_H
#define DIMER_H

#include "../../dependent_spec.h"
using namespace vd;

class Dimer : public DependentSpec<2>
{
public:
    static void find(BaseSpec *parent);

    using DependentSpec::DependentSpec;

    void findChildren();
};

#endif // DIMER_H
