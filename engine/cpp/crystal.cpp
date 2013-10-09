#include "crystal.h"
#include "atom.h"

namespace vd
{

Crystal::Crystal(const dim3 &sizes) : _atoms(sizes)
{
    atoms().mapIndex([](const uint3 &coords) {
        return 0;
    });
}

Crystal::~Crystal()
{
    atoms().each([](Atom *atom) {
        delete atom;
    });
}

void Crystal::initialize()
{
    buildAtoms();
    bondAllAtoms();

    findAllSpecs();
}

void Crystal::findAllSpecs()
{
    atoms().each([](Atom *atom) {
        atom->findSpecs();
    });
}

}
