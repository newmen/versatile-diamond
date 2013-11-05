#ifndef DIAMOND_RELATIONS_H
#define DIAMOND_RELATIONS_H

#include "../../atoms/neighbours.h"
#include "../../phases/crystal.h"

using namespace vd;

class Diamond;

struct DiamondRelations
{
    typedef Neighbours<2> TN;

    static TN front_110(const Crystal *crystal, const Atom *atom);
    static TN cross_110(const Crystal *crystal, const Atom *atom);
    static TN front_100(const Crystal *crystal, const Atom *atom);
    static TN cross_100(const Crystal *crystal, const Atom *atom);

    static int3 front_110(const Atom *first, const Atom *second);
};

#endif // DIAMOND_RELATIONS_H
