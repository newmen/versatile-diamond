#include "crystal.h"
#include "atom.h"
#include "compositionbuilder.h"

namespace vd
{

Crystal::Crystal(const dim3 &sizes, const CompositionBuilder *atomBuilder) : _atoms(sizes)
{
    _atoms.mapIndex([this, atomBuilder](const uint3 &coords) {
        return atomBuilder->build(this, coords);
    });
}

Crystal::~Crystal()
{
    _atoms.each([](Atom *atom) {
        delete atom;
    });
}

}
