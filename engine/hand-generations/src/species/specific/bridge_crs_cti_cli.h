#ifndef BRIDGE_CRS_CTI_CLI_H
#define BRIDGE_CRS_CTI_CLI_H

#include "bridge_crs.h"

class BridgeCRsCTiCLi : public Specific<Base<DependentSpec<BaseSpec>, BRIDGE_CRs_CTi_CLi, 3>>
{
public:
    static void find(BridgeCRs *parent);

    BridgeCRsCTiCLi(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    void findAllTypicalReactions() final;

    const ushort *indexes() const final { return __indexes; }
    const ushort *roles() const final { return __roles; }

private:
    static const ushort __indexes[3];
    static const ushort __roles[3];
};

#endif // BRIDGE_CRS_CTI_CLI_H
