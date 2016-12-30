#ifndef BRIDGE_WITH_DIMER_CBTI_CBRS_CDLI_H
#define BRIDGE_WITH_DIMER_CBTI_CBRS_CDLI_H

#include "bridge_with_dimer_cdli.h"

class BridgeWithDimerCBTiCBRsCDLi : public Specific<Base<DependentSpec<BaseSpec>, BRIDGE_WITH_DIMER_CBTi_CBRs_CDLi, 2>>
{
public:
    static void find(BridgeWithDimerCDLi *parent);

    BridgeWithDimerCBTiCBRsCDLi(ParentSpec *parent) : Specific(parent) {}

#if defined(PRINT) || defined(SPEC_PRINT) || defined(SERIALIZE)
    const char *name() const override;
#endif // PRINT || SPEC_PRINT || SERIALIZE

protected:
    void findAllTypicalReactions() final;
};

#endif // BRIDGE_WITH_DIMER_CBTI_CBRS_CDLI_H
