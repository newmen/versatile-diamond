#ifndef DIMER_CRS_H
#define DIMER_CRS_H

#include "../sidepiece/dimer.h"
#include "../specific.h"

class DimerCRs : public Specific<Base<DependentSpec<ParentSpec>, DIMER_CRs, 1>>
{
public:
    static void find(Dimer *parent);

    DimerCRs(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    void findAllChildren() final;
    void findAllTypicalReactions() final;

    const ushort *indexes() const final { return __indexes; }
    const ushort *roles() const final { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // DIMER_CRS_H
