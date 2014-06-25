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

    const ushort *indexes() const final { return __indexes; }
    const ushort *roles() const final { return __roles; }

private:
    static const ushort __indexes[3];
    static const ushort __roles[3];
};

#endif // ORIGINAL_BRIDGE_H
