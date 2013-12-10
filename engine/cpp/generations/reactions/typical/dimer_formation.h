#ifndef DIMERFORMATION_H
#define DIMERFORMATION_H

#include "../../../reactions/reaction_clarifier.h"
using namespace vd;

#include "../../species/specific/bridge_ctsi.h"
#include "../lateral/finders/dimer_formation_finder.h"
#include "../many_typical.h"

class DimerFormation : public ReactionClarifier<ManyTypical<DIMER_FORMATION, 2>, DimerFormationFinder>
{
public:
    static void find(BridgeCTsi *target);

//    using ReactionClarifier::ReactionClarifier;
    DimerFormation(SpecificSpec **targets) : ReactionClarifier(targets) {}

    double rate() const { return 1e5; }
    void doIt();

    std::string name() const override { return "dimer formation"; }

private:
    inline void changeAtom(Atom *atom) const;
};

#endif // DIMERFORMATION_H
