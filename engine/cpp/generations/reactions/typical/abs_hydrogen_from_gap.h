#ifndef ABS_HYDROGEN_FROM_GAP_H
#define ABS_HYDROGEN_FROM_GAP_H

#include "../../species/specific/bridge_crh.h"
#include "../typical.h"

class AbsHydrogenFromGap : public Typical<ABS_HYDROGEN_FROM_GAP, 2>
{
public:
    static void find(BridgeCRh *target);

    AbsHydrogenFromGap(SpecificSpec **targets) : Typical(targets) {}

    double rate() const { return 1e2; } // TODO: imagine
    void doIt();

    const std::string name() const override { return "abs hydrogen from gap"; }

private:
    void changeAtom(Atom *atom) const;
};

#endif // ABS_HYDROGEN_FROM_GAP_H
