#ifndef DIMERFORMATION_H
#define DIMERFORMATION_H

#include "../../../reactions/reaction_clarifier.h"
using namespace vd;

#include "../../species/specific/bridge_ctsi.h"
#include "../many_typical.h"

class DimerFormation : public ReactionClarifier<ManyTypical<DIMER_FORMATION, 2>>
{
public:
    static void find(BridgeCTsi *target);

    DimerFormation(SpecificSpec **targets) : ReactionClarifier(targets) {}

    double rate() const { return 1e5; }
    void doIt();

    std::string name() const override { return "dimer formation"; }

protected:
    LateralReaction *findLateral() override;

private:
    inline void changeAtom(Atom *atom) const;
};

#endif // DIMERFORMATION_H
