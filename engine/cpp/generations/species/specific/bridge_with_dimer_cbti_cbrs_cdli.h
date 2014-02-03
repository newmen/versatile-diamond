#ifndef BRIDGE_WITH_DIMER_CBTI_CBRS_CDLI_H
#define BRIDGE_WITH_DIMER_CBTI_CBRS_CDLI_H

#include "../base_specific.h"
#include "bridge_with_dimer_cdli.h"

class BridgeWithDimerCBTiCBRsCDLi :
        public BaseSpecific<DependentSpec<BaseSpec>, BRIDGE_WITH_DIMER_CBTi_CBRs_CDLi, 2>
{
public:
    static void find(BridgeWithDimerCDLi *parent);

    BridgeWithDimerCBTiCBRsCDLi(ParentSpec *parent) : BaseSpecific(parent) {}

#ifdef PRINT
    std::string name() const override { return "bridge_with_dimer(cbt: i, cbr: *, cdl: i)"; }
#endif // PRINT

protected:
    void findAllReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[2];
    static const ushort __roles[2];
};

#endif // BRIDGE_WITH_DIMER_CBTI_CBRS_CDLI_H
