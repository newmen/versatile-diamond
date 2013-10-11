#ifndef DIAMOND_H
#define DIAMOND_H

#include "../../crystal.h"
using namespace vd;

#include "../builders/diamond_atom_builder.h"
#include "diamond_relations.h"

template <class Relations>
class DiamondWithoutRelations : public Crystal, public Relations
{
public:
    using Crystal::Crystal;
};

class Diamond : public DiamondWithoutRelations<DiamondRelations>
{
    int _defaultSurfaceHeight;

public:
    Diamond(const dim3 &sizes, int defaultSurfaceHeight = 2);

protected:
    void buildAtoms() override;
    void bondAllAtoms() override;
    Atom *makeAtom(uint type, const int3 &coords) override;

private:
//    void bondWithFront110(Atom *atom);
    void bondWithCross110(Atom *atom);
    void bondWithNeighbours(Atom *atom, TN &neighbours);
};

#endif // DIAMOND_H
