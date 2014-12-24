#ifndef DIMER_CRI_CLI_H
#define DIMER_CRI_CLI_H

#include "../empty/symmetric_dimer_cri_cli.h"
#include "original_dimer_cri_cli.h"

class DimerCRiCLi : public Symmetric<OriginalDimerCRiCLi, SymmetricDimerCRiCLi>
{
public:
    static void find(Dimer *parent);

    DimerCRiCLi(ParentSpec *parent) : Symmetric(parent) {}

protected:
    void findAllChildren() final;
    void findAllTypicalReactions() final;
};

#endif // DIMER_CRI_CLI_H
