#ifndef BRIDGE_CRS_CTI_CLI_H
#define BRIDGE_CRS_CTI_CLI_H

#include "bridge_crs.h"

class BridgeCRsCTiCLi : public Specific<Base<DependentSpec<BaseSpec>, BRIDGE_CRs_CTi_CLi, 3>>
{
public:
    static void find(BridgeCRs *parent);

    BridgeCRsCTiCLi(ParentSpec *parent) : Specific(parent) {}

#if defined(PRINT) || defined(SPEC_PRINT) || defined(JSONLOG)
    const char *name() const override;
#endif // PRINT || SPEC_PRINT || JSONLOG

protected:
    void findAllTypicalReactions() final;
};

#endif // BRIDGE_CRS_CTI_CLI_H
