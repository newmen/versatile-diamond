#ifndef DIAMOND_RELATIONS_H
#define DIAMOND_RELATIONS_H

#include "../../atoms/neighbours.h"

using namespace vd;

class Diamond;

struct DiamondRelations
{
    typedef Neighbours<2> TN;

    static TN front_110(const Diamond *diamond, const Atom *atom);
    static TN cross_110(const Diamond *diamond, const Atom *atom);
    static TN front_100(const Diamond *diamond, const Atom *atom);
    static TN cross_100(const Diamond *diamond, const Atom *atom);
};

#endif // DIAMOND_RELATIONS_H
