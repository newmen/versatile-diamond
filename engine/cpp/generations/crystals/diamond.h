#ifndef DIAMOND_H
#define DIAMOND_H

#include "../../phases/crystal.h"
using namespace vd;

#include "diamond_relations.h"

class Diamond : public Crystal
{
    int _defaultSurfaceHeight;

public:
    Diamond(const dim3 &sizes, int defaultSurfaceHeight = 2);

    DiamondRelations::TN front_110(const Atom *atom) const { return DiamondRelations::front_110(this, atom); }
    DiamondRelations::TN cross_110(const Atom *atom) const { return DiamondRelations::cross_110(this, atom); }
    DiamondRelations::TN front_100(const Atom *atom) const { return DiamondRelations::front_100(this, atom); }
    DiamondRelations::TN cross_100(const Atom *atom) const { return DiamondRelations::cross_100(this, atom); }

protected:
    void buildAtoms() override;
    Atom *makeAtom(uint type, const int3 &coords) override;
    void bondAllAtoms() override;

    void findAll() override;

private:
//    void bondWithFront110(Atom *atom);
    void bondWithCross110(Atom *atom);
    void bondWithNeighbours(Atom *atom, DiamondRelations::TN &neighbours);
};

#endif // DIAMOND_H
