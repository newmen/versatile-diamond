#ifndef DIMERFORMATION_H
#define DIMERFORMATION_H

#include "../../species/specific/bridge_ctsi.h"
#include "../laterable.h"
#include "../many_typical.h"

class DimerFormation : public Laterable<ManyTypical<DIMER_FORMATION, 2>>
{
public:
    static void find(BridgeCTsi *target);

    DimerFormation(SpecificSpec **targets) : Laterable(targets) {}

    double rate() const { return 1e5; }
    void doIt();

    std::string name() const override { return "dimer formation"; }

protected:
    LateralReaction *findLateral() override;

private:
    inline void changeAtom(Atom *atom) const;
};

#endif // DIMERFORMATION_H
