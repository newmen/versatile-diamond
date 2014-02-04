#ifndef BRIDGE_H
#define BRIDGE_H

#include "../base.h"
#include "../component.h"

class Bridge : public Component<Base<SourceSpec<ParentSpec, 3>, BRIDGE, 3>>
{
public:
    static void find(Atom *anchor);

    Bridge(Atom **atoms) : Component(atoms) {}

#ifdef PRINT
    std::string name() const override { return "bridge"; }
#endif // PRINT

    void findComplexSpecies() override;
protected:
    void findAllChildren() override;

    const ushort *indexes() const override { return __indexes; }
    const ushort *roles() const override { return __roles; }

private:
    static const ushort __indexes[3];
    static const ushort __roles[3];
};

#endif // BRIDGE_H
