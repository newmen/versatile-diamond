#ifndef BRIDGE_CTSI_H
#define BRIDGE_CTSI_H

#include "../specific.h"
#include "../base/bridge.h"

class BridgeCTsi : public Specific<BRIDGE_CTsi, 1>
{
public:
    static void find(Bridge *parent);

    BridgeCTsi(BaseSpec *parent) : Specific(parent) {}

#ifdef PRINT
    std::string name() const override { return "bridge(ct: *, ct: i)"; }
#endif // PRINT

    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

protected:
    void findAllReactions() override;

private:
    static ushort __indexes[1];
    static ushort __roles[1];
};

#endif // BRIDGE_CTSI_H
