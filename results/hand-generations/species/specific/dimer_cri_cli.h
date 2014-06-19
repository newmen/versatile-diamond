#ifndef DIMER_CRI_CLI_H
#define DIMER_CRI_CLI_H

#include "../sidepiece/dimer.h"
#include "../specific.h"

class DimerCRiCLi : public Specific<Base<DependentSpec<BaseSpec>, DIMER_CRi_CLi, 2>>
{
public:
    static void find(Dimer *parent);

    DimerCRiCLi(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    void findAllTypicalReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[2];
    static const ushort __roles[2];
};

#endif // DIMER_CRI_CLI_H
