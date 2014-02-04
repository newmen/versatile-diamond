#ifndef AS_COMPONENT_H
#define AS_COMPONENT_H

namespace vd
{

class ComponentSpec
{
protected:
    ComponentSpec() = default;

public:
    virtual void findComplexSpecies() = 0;
};

}

#endif // AS_COMPONENT_H
