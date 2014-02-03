#ifndef DIMER_DROP_H
#define DIMER_DROP_H

#include "../../species/specific/dimer_cri_cli.h"
#include "../laterable_role.h"
#include "../typical.h"

class DimerDrop : public LaterableRole<Typical, DIMER_DROP, 1>
{
public:
    static constexpr double RATE = 2.2e6 * exp(-0.8e3 / (1.98 * Env::T));

    static void find(DimerCRiCLi *target);

    template <class L>
    static void ifTarget(Atom **atoms, const L &lambda);

    DimerDrop(SpecificSpec *target) : LaterableRole(target) {}

    double rate() const override { return RATE; }
    void doIt() override;

    std::string name() const override { return "dimer drop"; }

protected:
    LateralReaction *findAllLateral() override;

private:
    inline void changeAtom(Atom *atom) const;
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class L>
void DimerDrop::ifTarget(Atom **atoms, const L &lambda)
{
    if (atoms[0]->is(20) && atoms[1]->is(20))
    {
        SpecificSpec *targets[2] = {
            atoms[0]->specByRole<DimerCRiCLi>(20),
            atoms[1]->specByRole<DimerCRiCLi>(20)
        };

        if (targets[0] && targets[0] == targets[1])
        {
            lambda(targets[0]);
        }
    }
}

#endif // DIMER_DROP_H
