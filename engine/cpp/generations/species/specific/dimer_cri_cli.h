#ifndef DIMER_CRI_CLI_H
#define DIMER_CRI_CLI_H

#include "../sidepiece/dimer.h"
#include "../base_specific.h"

class DimerCRiCLi : public BaseSpecific<DependentSpec<BaseSpec>, DIMER_CRi_CLi, 2>
{
public:
    static void find(Dimer *parent);

    DimerCRiCLi(ParentSpec *parent) : BaseSpecific(parent) {}

#ifdef PRINT
    std::string name() const override { return "dimer(cr: i, cl: i)"; }
#endif // PRINT

protected:
    void findAllReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[2];
    static const ushort __roles[2];
};

#endif // DIMER_CRI_CLI_H
