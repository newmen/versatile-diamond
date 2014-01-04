#ifndef DIAMOND_H
#define DIAMOND_H

#include "../../phases/crystal.h"
using namespace vd;

#include "diamond_relations.h"

class Diamond : public DiamondRelations<Crystal>
{
    int _defaultSurfaceHeight;

public:
#ifndef NDEBUG
    typedef DiamondRelations<Crystal> Relations;
#endif // NDEBUG

    Diamond(const dim3 &sizes, int defaultSurfaceHeight = 2);
    ~Diamond();

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
