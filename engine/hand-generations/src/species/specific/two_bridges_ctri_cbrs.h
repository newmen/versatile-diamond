#ifndef TWO_BRIDGES_CTRI_CBRS_H
#define TWO_BRIDGES_CTRI_CBRS_H

#include "../base/two_bridges.h"
#include "../specific.h"

class TwoBridgesCTRiCBRs : public Specific<Base<DependentSpec<BaseSpec>, TWO_BRIDGES_CTRi_CBRs, 2>>
{
public:
    static void find(TwoBridges *parent);

    TwoBridgesCTRiCBRs(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    void findAllTypicalReactions() final;
};

#endif // TWO_BRIDGES_CTRI_CBRS_H
