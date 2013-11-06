#ifndef DIMERFORMATION_H
#define DIMERFORMATION_H

#include "../../specific_specs/bridge_ctsi.h"
#include "../many_typical.h"

class DimerFormation :
        public ManyTypical<DIMER_FORMATION, SCA_DIMER_FORMATION, 2>
{
public:
    static void find(BridgeCTsi *target);

//    using ManyTypical::ManyTypical;
    DimerFormation(SpecificSpec **targets) : ManyTypical(targets) {}

    double rate() const { return 1e5; }
    void doIt();

#ifdef PRINT
    std::string name() const override { return "dimer formation"; }
#endif // PRINT

private:
    inline void changeAtom(Atom *atom) const;
};

#endif // DIMERFORMATION_H
