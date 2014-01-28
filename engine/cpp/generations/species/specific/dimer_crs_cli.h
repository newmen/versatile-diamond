#ifndef DIMER_CRS_CLI_H
#define DIMER_CRS_CLI_H

#include "../base_specific.h"
#include "dimer_crs.h"

class DimerCRsCLi : public BaseSpecific<DependentSpec<BaseSpec>, DIMER_CRs_CLi, 2>
{
public:
    static void find(DimerCRs *parent);

    DimerCRsCLi(ParentSpec *parent) : BaseSpecific(parent) {}

#ifdef PRINT
    const std::string name() const override { return "dimer(cr: *, cl: i)"; }
#endif // PRINT

protected:
    void findAllReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[2];
    static const ushort __roles[2];
};

#endif // DIMER_CRS_CLI_H
