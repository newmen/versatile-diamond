#ifndef TWO_BRIDGES_CBRS_H
#define TWO_BRIDGES_CBRS_H

#include "../base/two_bridges.h"
#include "../specific.h"

class TwoBridgesCBRs : public Specific<DependentSpec<BaseSpec>, TWO_BRIDGES_CBRs, 1>
{
public:
    static void find(TwoBridges *parent);

    TwoBridgesCBRs(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    std::string name() const override { return "two_bridges(cbr: *)"; }
#endif // PRINT

    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

protected:
    void findAllReactions() override;

private:
    static ushort __indexes[1];
    static ushort __roles[1];
};

#endif // TWO_BRIDGES_CBRS_H
