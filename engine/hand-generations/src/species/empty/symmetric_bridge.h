#ifndef SYMMETRIC_BRIDGE_H
#define SYMMETRIC_BRIDGE_H

#include "../base/original_bridge.h"
#include "../empty_base.h"

class SymmetricBridge : public AtomsSwapWrapper<EmptyBase<BRIDGE>, 1, 2>
{
public:
    SymmetricBridge(OriginalBridge *parent) : AtomsSwapWrapper(parent) {}

#if defined(PRINT) || defined(SPEC_PRINT) || defined(SERIALIZE)
    const char *name() const override;
#endif // PRINT || SPEC_PRINT || SERIALIZE
};

#endif // SYMMETRIC_BRIDGE_H
