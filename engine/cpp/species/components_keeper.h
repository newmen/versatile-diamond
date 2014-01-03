#ifndef COMPONENTS_KEEPER_H
#define COMPONENTS_KEEPER_H

#include "../tools/collector.h"
#include "component_spec.h"

namespace vd
{

class ComponentsKeeper : public Collector<ComponentSpec>
{
    typedef Collector<ComponentSpec> ParentType;

public:
    void findComplexSpecies();
};

}

#endif // COMPONENTS_KEEPER_H
