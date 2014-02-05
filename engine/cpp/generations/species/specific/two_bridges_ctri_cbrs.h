#ifndef TWO_BRIDGES_CTRI_CBRS_H
#define TWO_BRIDGES_CTRI_CBRS_H

#include "../base/two_bridges.h"
#include "../base.h"
#include "../specific.h"

class TwoBridgesCTRiCBRs : public Specific<Base<DependentSpec<BaseSpec>, TWO_BRIDGES_CTRi_CBRs, 1>>
{
public:
    static void find(TwoBridges *parent);

    TwoBridgesCTRiCBRs(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    std::string name() const override { return "two_bridges(ctr: i, cbr: *)"; }
#endif // PRINT

protected:
    void findAllTypicalReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // TWO_BRIDGES_CTRI_CBRS_H
