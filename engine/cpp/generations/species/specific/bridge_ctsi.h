#ifndef BRIDGE_CTSI_H
#define BRIDGE_CTSI_H

#include "../specific.h"
#include "../base/bridge.h"

class BridgeCTsi : public Specific<BRIDGE_CTsi, 1>
{
public:
    static void find(Bridge *parent);

//    using Specific<BRIDGE_CTsi, 1>::Specific;
    BridgeCTsi(BaseSpec *parent) : Specific(parent) {}

#ifdef PRINT
    std::string name() const override { return "bridge(ct: *, ct: i)"; }
#endif // PRINT

    void findAllReactions() override;

protected:
    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

private:
    static ushort __indexes[1];
    static ushort __roles[1];
};

#endif // BRIDGE_CTSI_H
