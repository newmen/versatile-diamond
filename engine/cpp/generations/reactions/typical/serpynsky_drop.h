#ifndef SERPYNSKY_DROP_H
#define SERPYNSKY_DROP_H

#include "../../species/specific/cross_bridge_on_bridges.h"
#include "../typical.h"

class SerpynskyDrop : public Typical<SERPYNSKY_DROP>
{
    static const char __name[];

public:
    static const double RATE;

    static void find(CrossBridgeOnBridges *target);

    SerpynskyDrop(SpecificSpec *target) : Typical(target) {}

    void doIt() override;

    double rate() const override { return RATE; }
    const char *name() const override { return __name; }
};

#endif // SERPYNSKY_DROP_H
