#ifndef SYMMETRIC_BRIDGE_H
#define SYMMETRIC_BRIDGE_H

#include "../base/original_bridge.h"
#include "../empty_base.h"

class SymmetricBridge : public AtomsSwapWrapper<EmptyBase<BRIDGE>, 1, 2>
{
public:
    SymmetricBridge(OriginalBridge *parent) : AtomsSwapWrapper(parent) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT
};

#endif // SYMMETRIC_BRIDGE_H
