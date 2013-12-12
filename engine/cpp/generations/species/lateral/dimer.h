#ifndef DIMER_H
#define DIMER_H

#include "../base/unwrapped_dimer.h"
#include "../lateral.h"

class Dimer : public Lateral<UnwrappedDimer>
{
public:
    static void find(Atom *anchor);

    template <class... Args>
    Dimer(Args... args) : Lateral(args...) {}

protected:
    void findAllChildren() override;
    void findAllReactions() override;
};

#endif // DIMER_H
