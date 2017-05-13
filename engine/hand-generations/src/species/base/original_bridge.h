#ifndef ORIGINAL_BRIDGE_H
#define ORIGINAL_BRIDGE_H

#include "../base.h"

class OriginalBridge : public Base<SourceSpec<ParentSpec, 3>, BRIDGE, 3>
{
public:
#if defined(PRINT) || defined(SPEC_PRINT) || defined(JSONLOG)
    const char *name() const override;
#endif // PRINT || SPEC_PRINT || JSONLOG

protected:
    OriginalBridge(Atom **atoms) : Base(atoms) {}
};

#endif // ORIGINAL_BRIDGE_H
