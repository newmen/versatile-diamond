#ifndef DIMERFORMATION_H
#define DIMERFORMATION_H

#include "../../species/specific/bridge_ctsi.h"
#include "../laterable_role.h"
#include "../typical.h"

class DimerFormation : public LaterableRole<Typical, DIMER_FORMATION, 2>
{
public:
    static void find(BridgeCTsi *target);

    DimerFormation(SpecificSpec **targets) : LaterableRole(targets) {}

    double rate() const { return 1e5; }
    void doIt();

    std::string name() const override { return "dimer formation"; }

protected:
    LateralReaction *findAllLateral() override;

private:
    inline void changeAtom(Atom *atom) const;
};

#endif // DIMERFORMATION_H
