#ifndef ORIGINAL_BRIDGE_H
#define ORIGINAL_BRIDGE_H

#include "../base.h"

class OriginalBridge : public Base<SourceSpec<ParentSpec, 3>, BRIDGE, 3>
{
public:
#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    OriginalBridge(Atom **atoms) : Base(atoms) {}
};

#endif // ORIGINAL_BRIDGE_H
