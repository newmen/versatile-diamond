#ifndef BRIDGE_CRS_CTI_CLI_H
#define BRIDGE_CRS_CTI_CLI_H

#include "../specific.h"
#include "bridge_crs.h"

class BridgeCRsCTiCLi : public Specific<DependentSpec<BaseSpec>, BRIDGE_CRs_CTi_CLi, 3>
{
public:
    static void find(BridgeCRs *parent);

    BridgeCRsCTiCLi(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    std::string name() const override { return "bridge(cr: *, ct: i, cl: i)"; }
#endif // PRINT

    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

protected:
    void findAllReactions() override;

private:
    static ushort __indexes[3];
    static ushort __roles[3];
};

#endif // BRIDGE_CRS_CTI_CLI_H
