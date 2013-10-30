#ifndef DIMERFORMATION_H
#define DIMERFORMATION_H

#include "../../../reactions/few_specs_reaction.h"
using namespace vd;

class DimerFormation : public FewSpecsReaction<2>
{
public:
    static void find(SpecificSpec *parent);

    using FewSpecsReaction::FewSpecsReaction;

    double rate() const { return 1e5; }
    void doIt();

#ifdef PRINT
    std::string name() const override { return "dimer formation"; }
#endif // PRINT

protected:
    void remove() override;

private:
    static void checkAndAdd(SpecificSpec *parent, Atom *neighbour);

    void changeAtom(Atom *atom) const;
};

#endif // DIMERFORMATION_H
