#ifndef DIMER_H
#define DIMER_H

#include "../sidepiece.h"

class Dimer : public Sidepiece<DependentSpec<ParentSpec, 2>, DIMER, 2>
{
public:
    static void find(Atom *anchor);

    template <class L>
    static void dimersRow(Atom **anchors, const L &lambda);

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

template <class L>
void Dimer::dimersRow(Atom **anchors, const L &lambda)
{
    eachNeighbours<2>(anchors, &Diamond::cross_100, [&lambda](Atom **neighbours) {
        if (neighbours[0]->is(22) && neighbours[1]->is(22))
        {
            LateralSpec *specsInNeighbour[2] = {
                neighbours[0]->specByRole<Dimer>(22),
                neighbours[1]->specByRole<Dimer>(22)
            };

            auto lateralSpec = specsInNeighbour[0];
            if (lateralSpec && specsInNeighbour[0] == specsInNeighbour[1])
            {
                lambda(lateralSpec);
            }
        }
    });
}

#endif // DIMER_H
