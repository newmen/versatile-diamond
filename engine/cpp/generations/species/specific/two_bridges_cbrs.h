#ifndef TWO_BRIDGES_CBRS_H
#define TWO_BRIDGES_CBRS_H

#include "../base/two_bridges.h"
#include "../base_specific.h"

class TwoBridgesCBRs : public BaseSpecific<DependentSpec<BaseSpec>, TWO_BRIDGES_CBRs, 1>
{
public:
    static void find(TwoBridges *parent);

    TwoBridgesCBRs(ParentSpec *parent) : BaseSpecific(parent) {}

#ifdef PRINT
    std::string name() const override { return "two_bridges(cbr: *)"; }
#endif // PRINT

protected:
    void findAllReactions() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[1];
    static const ushort __roles[1];
};

#endif // TWO_BRIDGES_CBRS_H
