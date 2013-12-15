#ifndef BRIDGE_H
#define BRIDGE_H

#include "../base.h"

class Bridge : public Base<SourceSpec<ParentSpec, 3>, BRIDGE, 3>
{
public:
    static void find(Atom *anchor);

    Bridge(Atom **atoms) : Base(atoms) {}

#ifdef PRINT
    std::string name() const override { return "bridge"; }
#endif // PRINT

    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

protected:
    void findAllChildren() override;

private:
    static ushort __indexes[3];
    static ushort __roles[3];
};

#endif // BRIDGE_H
