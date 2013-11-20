#ifndef BRIDGE_CRS_CTI_CLI_H
#define BRIDGE_CRS_CTI_CLI_H

#include "../specific.h"
#include "bridge_crs.h"

class BridgeCRsCTiCLi : public Specific<BRIDGE_CRs_CTi_CLi, 3>
{
public:
    static void find(BridgeCRs *parent);

//    using Specific<BRIDGE_CRs_CTi, 1>::Specific;
    BridgeCRsCTiCLi(BaseSpec *parent) : Specific(parent) {}

#ifdef PRINT
    std::string name() const override { return "bridge(cr: *, ct: i, cl: i)"; }
#endif // PRINT

    void findAllReactions() override;

protected:
    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

private:
    static ushort __indexes[3];
    static ushort __roles[3];
};

#endif // BRIDGE_CRS_CTI_CLI_H
