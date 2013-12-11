#ifndef DIMER_H
#define DIMER_H

#include "../base/unwrapped_dimer.h"
#include "../sidepiece.h"

class Dimer : public Sidepiece<UnwrappedDimer>
{
public:
    static void find(Atom *anchor);

    template <class... Args>
    Dimer(Args... args) : Sidepiece(args...) {}

protected:
    void findAllChildren() override;
    void findAllReactions() override;
};

#endif // DIMER_H
