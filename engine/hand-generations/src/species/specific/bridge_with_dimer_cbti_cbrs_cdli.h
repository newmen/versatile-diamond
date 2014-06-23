#ifndef BRIDGE_WITH_DIMER_CBTI_CBRS_CDLI_H
#define BRIDGE_WITH_DIMER_CBTI_CBRS_CDLI_H

#include "bridge_with_dimer_cdli.h"

class BridgeWithDimerCBTiCBRsCDLi : public Specific<Base<DependentSpec<BaseSpec>, BRIDGE_WITH_DIMER_CBTi_CBRs_CDLi, 2>>
{
public:
    static void find(BridgeWithDimerCDLi *parent);

    BridgeWithDimerCBTiCBRsCDLi(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    void findAllTypicalReactions() final;

    const ushort *indexes() const final { return __indexes; }
    const ushort *roles() const final { return __roles; }

private:
    static const ushort __indexes[2];
    static const ushort __roles[2];
};

#endif // BRIDGE_WITH_DIMER_CBTI_CBRS_CDLI_H
