#ifndef DIMER_DROP_H
#define DIMER_DROP_H

#include "../../../reactions/mono_spec_reaction.h"
using namespace vd;

#include "../../specific_specs/dimer_cri_cli.h"

class DimerDrop : public MonoSpecReaction
{
public:
    static void find(DimerCRiCLi *target);

//    using MonoSpecReaction::MonoSpecReaction;
    DimerDrop(SpecificSpec *target) : MonoSpecReaction(target) {}

    double rate() const { return 5e4; }
    void doIt();

#ifdef PRINT
    std::string name() const override { return "dimer drop"; }
#endif // PRINT

protected:
    void remove() override;

private:
    void changeAtom(Atom *atom) const;
};

#endif // DIMER_DROP_H
