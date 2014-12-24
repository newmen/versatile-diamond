#ifndef DIMER_CRS_CLI_H
#define DIMER_CRS_CLI_H

#include "dimer_cri_cli.h"

class DimerCRsCLi : public Specific<Base<DependentSpec<BaseSpec>, DIMER_CRs_CLi, 1>>
{
public:
    static void find(DimerCRiCLi *parent);

    DimerCRsCLi(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    void findAllTypicalReactions() final;
};

#endif // DIMER_CRS_CLI_H
