#ifndef BRIDGE_H
#define BRIDGE_H

#include "../base.h"

class Bridge :
        public Base<SourceSpec<ParentSpec, 3>, BRIDGE, 3>,
        public ComponentSpec
{
public:
    static void find(Atom *anchor);

    Bridge(Atom **atoms) : Base(atoms) {}

#ifdef PRINT
    const std::string name() const override { return "bridge"; }
#endif // PRINT

    void findAllComplexes() override;
protected:
    void findAllChildren() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[3];
    static const ushort __roles[3];
};

#endif // BRIDGE_H
