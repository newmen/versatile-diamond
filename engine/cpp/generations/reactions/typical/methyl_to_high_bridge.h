#ifndef METHYL_TO_HIGH_BRIDGE_H
#define METHYL_TO_HIGH_BRIDGE_H

#include "../../../reactions/mono_spec_reaction.h"
using namespace vd;

#include "../../specific_specs/methyl_on_dimer_cmsu.h"

class MethylToHighBridge : public MonoSpecReaction
{
public:
    static void find(MethylOnDimerCMsu *target);

//    using MonoSpecReaction::MonoSpecReaction;
    MethylToHighBridge(SpecificSpec *target) : MonoSpecReaction(target) {}

    double rate() const { return 5e5; }
    void doIt();

#ifdef PRINT
    std::string name() const override { return "methyl to high bridge"; }
#endif // PRINT

protected:
    void remove() override;
};

#endif // METHYL_TO_HIGH_BRIDGE_H
