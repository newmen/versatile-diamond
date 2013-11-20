#ifndef DIMER_H
#define DIMER_H

#include "../dependent.h"

class Dimer : public Dependent<DIMER, 2>
{
public:
    static void find(Atom *anchor);

//    using Dependent<DIMER, 2>::Dependent;
    Dimer(BaseSpec **parents) : Dependent(parents) {}

#ifdef PRINT
    std::string name() const override { return "dimer"; }
#endif // PRINT

    void findAllChildren() override;

protected:
    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

private:
    static ushort __indexes[2];
    static ushort __roles[2];

    static void checkAndAdd(Atom *anchor, Atom *neighbour);
};

#endif // DIMER_H
