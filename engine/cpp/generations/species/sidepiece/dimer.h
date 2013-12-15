#ifndef DIMER_H
#define DIMER_H

#include "../sidepiece.h"

class Dimer : public Sidepiece<DependentSpec<ParentSpec, 2>, DIMER, 2>
{
public:
    static void find(Atom *anchor);

    Dimer(ParentSpec **parents) : Sidepiece(parents) {}

#ifdef PRINT
    std::string name() const override { return "dimer"; }
#endif // PRINT

    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

protected:
    void findAllChildren() override;
    void findAllReactions() override;

private:
    static ushort __indexes[2];
    static ushort __roles[2];
};

#endif // DIMER_H
