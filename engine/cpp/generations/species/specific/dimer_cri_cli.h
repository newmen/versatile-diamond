#ifndef DIMER_CRI_CLI_H
#define DIMER_CRI_CLI_H

#include "../specific.h"
#include "../base/dimer.h"

class DimerCRiCLi : public Specific<DIMER_CRi_CLi, 2>
{
public:
    static void find(Dimer *parent);

//    using Specific<DIMER_CRi_CLi, 2>::Specific;
    DimerCRiCLi(BaseSpec *parent) : Specific(parent) {}

#ifdef PRINT
    std::string name() const override { return "dimer(cr: i, cl: i)"; }
#endif // PRINT

    void findChildren() override;

protected:
    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

private:
    static ushort __indexes[2];
    static ushort __roles[2];
};

#endif // DIMER_CRI_CLI_H
