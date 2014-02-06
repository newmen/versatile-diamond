#ifndef ABS_HYDROGEN_FROM_GAP_H
#define ABS_HYDROGEN_FROM_GAP_H

#include "../../species/specific/bridge_crh.h"
#include "../typical.h"

class AbsHydrogenFromGap : public Typical<ABS_HYDROGEN_FROM_GAP, 2>
{
    static const char __name[];

public:
    static const double RATE;

    static void find(BridgeCRh *target);

    AbsHydrogenFromGap(SpecificSpec **targets) : Typical(targets) {}

    void doIt() override;

    double rate() const override { return RATE; }
    const char *name() const override { return __name; }

private:
    void changeAtom(Atom *atom) const;
};

#endif // ABS_HYDROGEN_FROM_GAP_H
