#ifndef DIAMOND_H
#define DIAMOND_H

#include <phases/crystal.h>
#include <phases/behavior.h>
using namespace vd;

#include "diamond_crystal_properties.h"

class Diamond : public DiamondCrystalProperties<Crystal>
{
    int _defaultSurfaceHeight;

public:
    typedef DiamondRelations<Crystal> Relations;

    Diamond(const dim3 &sizes, const Behavior *behavior, int defaultSurfaceHeight = 3);
    ~Diamond();

protected:
    void buildAtoms() final;
    void bondAllAtoms() final;
    void detectAtomTypes() final;

    void findAll() final;

    Atom *makeAtom(ushort type, ushort actives, const int3 &coords) final;
    bool hasBottom(const int3 &coords) final;

private:
    ushort detectType(const Atom *atom);

    template <class RL>
    ushort countCrystalNeighbours(const Atom *atom, const RL &relationsMethod);
};

//////////////////////////////////////////////////////////////////////////////////////

template <class RL>
ushort Diamond::countCrystalNeighbours(const Atom *atom, const RL &relationsMethod)
{
    ushort result = 0;
    (this->*relationsMethod)(atom).each([atom, &result](Atom *nbr) {
        if (atom->hasBondWith(nbr))
        {
            ++result;
        }
    });

    return result;
}

#endif // DIAMOND_H
