#ifndef DIMER_DROP_H
#define DIMER_DROP_H

#include "../../species/specific/dimer_cri_cli.h"
#include "../laterable_role.h"
#include "../typical.h"

class DimerDrop : public LaterableRole<Typical, DIMER_DROP, 1>
{
public:
    static void find(DimerCRiCLi *target);

    DimerDrop(SpecificSpec *target) : LaterableRole(target) {}

    double rate() const { return 5e3; }
    void doIt();

    std::string name() const override { return "dimer drop"; }

protected:
    LateralReaction *findAllLateral() override;

private:
    inline void changeAtom(Atom *atom) const;
};

#endif // DIMER_DROP_H
