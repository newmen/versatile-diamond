#ifndef BRIDGE_CRS_CTI_H
#define BRIDGE_CRS_CTI_H

#include "../specific.h"
#include "bridge_crs.h"

class BridgeCRsCTi : public Specific<BRIDGE_CRs_CTi, 2>
{
public:
    static void find(BridgeCRs *parent);

//    using Specific<BRIDGE_CRs_CTi, 1>::Specific;
    BridgeCRsCTi(BaseSpec *parent) : Specific(parent) {}

#ifdef PRINT
    std::string name() const override { return "bridge(cr: *, ct: i)"; }
#endif // PRINT

    void findAllReactions() override;

protected:
    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

private:
    static ushort __indexes[2];
    static ushort __roles[2];
};

#endif // BRIDGE_CRS_CTI_H
