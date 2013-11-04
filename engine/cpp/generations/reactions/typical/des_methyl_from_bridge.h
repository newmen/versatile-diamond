#ifndef DES_METHYL_FROM_BRIDGE_H
#define DES_METHYL_FROM_BRIDGE_H

#include "../../../reactions/mono_spec_reaction.h"
using namespace vd;

#include "../../specific_specs/methyl_on_bridge_cbi_cmu.h"

class DesMethylFromBridge : public MonoSpecReaction
{
public:
    static void find(MethylOnBridgeCBiCMu *target);

//    using MonoSpecReaction::MonoSpecReaction;
    DesMethylFromBridge(SpecificSpec *target) : MonoSpecReaction(target) {}

    double rate() const { return 1e4; }
    void doIt();

#ifdef PRINT
    std::string name() const override { return "desorption methyl from bridge"; }
#endif // PRINT

protected:
    void remove() override;
};

#endif // DES_METHYL_FROM_BRIDGE_H
