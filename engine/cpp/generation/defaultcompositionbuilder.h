#ifndef DEFAULTCOMPOSITIONBUILDER_H
#define DEFAULTCOMPOSITIONBUILDER_H

#include "../compositionbuilder.h"
using namespace vd;

class DefaultCompositionBuilder : public CompositionBuilder
{
public:
    Atom *build(const Crystal *crystal, const uint3 &coords) const;
};

#endif // DEFAULTCOMPOSITIONBUILDER_H
