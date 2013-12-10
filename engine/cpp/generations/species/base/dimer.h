#ifndef DIMER_H
#define DIMER_H

#include "../dependent.h"

class Dimer : public Dependent<DIMER, 2>
{
public:
    static void find(Atom *anchor);

//    using Dependent::Dependent;
    Dimer(BaseSpec **parents) : Dependent(parents) {}

#ifdef PRINT
    std::string name() const override { return "dimer"; }
#endif // PRINT

protected:
    void findAllChildren() override;
//    void findAllReactions() override;

    ushort *indexes() const override { return __indexes; }
    ushort *roles() const override { return __roles; }

private:
    static ushort __indexes[2];
    static ushort __roles[2];
};

#endif // DIMER_H
