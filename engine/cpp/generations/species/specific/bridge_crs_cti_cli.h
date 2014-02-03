#ifndef BRIDGE_CRS_CTI_CLI_H
#define BRIDGE_CRS_CTI_CLI_H

#include "../base_specific.h"
#include "bridge_crs.h"

class BridgeCRsCTiCLi : public BaseSpecific<DependentSpec<BaseSpec>, BRIDGE_CRs_CTi_CLi, 3>
{
public:
    static void find(BridgeCRs *parent);

    BridgeCRsCTiCLi(ParentSpec *parent) : BaseSpecific(parent) {}

#ifdef PRINT
    std::string name() const override { return "bridge(cr: *, ct: i, cl: i)"; }
#endif // PRINT

protected:
    void findAllReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[3];
    static const ushort __roles[3];
};

#endif // BRIDGE_CRS_CTI_CLI_H
