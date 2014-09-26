#ifndef SIERPINSKI_DROP_H
#define SIERPINSKI_DROP_H

#include "../../species/specific/cross_bridge_on_bridges.h"
#include "../typical.h"

class SierpinskiDrop : public Typical<SIERPINSKI_DROP>
{
    static const char __name[];

public:
    static double RATE();

    static void find(CrossBridgeOnBridges *target);

    SierpinskiDrop(SpecificSpec *target) : Typical(target) {}

    double rate() const override { return RATE(); }
    const char *name() const override { return __name; }

protected:
    void doItWith(Atom **atoms);
    void changeAtoms(Atom **atoms) final;
};

#endif // SIERPINSKI_DROP_H
