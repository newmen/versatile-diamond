#ifndef BRIDGE_H
#define BRIDGE_H

#include "../source.h"

class Bridge : public Source<BRIDGE, 3>
{
public:
    static void find(Atom *anchor);

//    using Source<BRIDGE, 3>::Source;
    Bridge(Atom **atoms) : Source(atoms) {}

#ifdef PRINT
    std::string name() const override { return "bridge"; }
#endif // PRINT

    void findAllChildren() override;

protected:
    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

private:
    static ushort __indexes[3];
    static ushort __roles[3];
};

#endif // BRIDGE_H
