#ifndef DIMER_DROP_H
#define DIMER_DROP_H

#include "../../species/specific/dimer_cri_cli.h"
#include "../typical.h"

class DimerDrop : public Typical<DIMER_DROP>
{
public:
    static void find(DimerCRiCLi *target);

    DimerDrop(SpecificSpec *target) : Typical(target) {}

    double rate() const { return 5e3; }
    void doIt();

    std::string name() const override { return "dimer drop"; }

private:
    void changeAtom(Atom *atom) const;
};

#endif // DIMER_DROP_H
