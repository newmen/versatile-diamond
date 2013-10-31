#ifndef DIMERFORMATION_H
#define DIMERFORMATION_H

#include "../../../reactions/few_specs_reaction.h"
using namespace vd;

#include "../../specific_specs/bridge_ctsi.h"

class DimerFormation : public FewSpecsReaction<2>
{
public:
    static void find(BridgeCTsi *target);

//    using FewSpecsReaction::FewSpecsReaction;
    DimerFormation(SpecificSpec **targets) : FewSpecsReaction<2>(targets) {}

    double rate() const { return 1e5; }
    void doIt();

#ifdef PRINT
    std::string name() const override { return "dimer formation"; }
#endif // PRINT

protected:
    void remove() override;

private:
    static void checkAndAdd(BridgeCTsi *target, Atom *neighbour);

    void changeAtom(Atom *atom) const;
};

#endif // DIMERFORMATION_H
