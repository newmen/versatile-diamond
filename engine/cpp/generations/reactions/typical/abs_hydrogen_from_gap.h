#ifndef ABS_HYDROGEN_FROM_GAP_H
#define ABS_HYDROGEN_FROM_GAP_H

#include "../../species/specific/bridge_crh.h"
#include "../typical.h"

class AbsHydrogenFromGap : public Typical<ABS_HYDROGEN_FROM_GAP, 2>
{
public:
    static constexpr double RATE = 3e14 * exp(-35e3 / (1.98 * Env::T)); // REAL: A = 3e5

    static void find(BridgeCRh *target);

    AbsHydrogenFromGap(SpecificSpec **targets) : Typical(targets) {}

    double rate() const override { return RATE; }
    void doIt() override;

    const char *name() const override;

private:
    void changeAtom(Atom *atom) const;
};

#endif // ABS_HYDROGEN_FROM_GAP_H
