#include "migration_through_dimers_row.h"

const char MigrationThroughDimersRow::__name[] = "migration through dimers row";

double MigrationThroughDimersRow::RATE()
{
    static double value = getRate("MIGRATION_THROUGH_DIMERS_ROW");
    return value;
}

void MigrationThroughDimersRow::find(MethylOnDimerCMsiu *target)
{
    Atom *anchors[2] = { target->atom(1), target->atom(4) };
    eachNeighbours<2>(anchors, &Diamond::cross_100, [target](Atom **neighbours) {
        if (neighbours[0]->is(21) && neighbours[0]->hasBondWith(neighbours[1]))
        {
            auto neighbourSpec = neighbours[0]->specByRole<DimerCRs>(21);
            if (neighbourSpec)
            {
                SpecificSpec *targets[2] = {
                    target,
                    neighbourSpec
                };

                create<MigrationThroughDimersRow>(targets);
            }
        }
    });
}

void MigrationThroughDimersRow::find(DimerCRs *target)
{
    Atom *anchors[2] = { target->atom(0), target->atom(3) };
    eachNeighbours<2>(anchors, &Diamond::cross_100, [target](Atom **neighbours) {
        if (neighbours[0]->is(23) && neighbours[0]->hasBondWith(neighbours[1]))
        {
            auto neighbourSpec = neighbours[0]->specByRole<MethylOnDimerCMsiu>(23);
            if (neighbourSpec)
            {
                SpecificSpec *targets[2] = {
                    neighbourSpec,
                    target
                };

                create<MigrationThroughDimersRow>(targets);
            }
        }
    });

}

void MigrationThroughDimersRow::doIt()
{
    SpecificSpec *methylOnDimer = target(0);
    SpecificSpec *dimer = target(1);

    assert(methylOnDimer->type() == MethylOnDimerCMsiu::ID);
    assert(dimer->type() == DimerCRs::ID);

    Atom *atoms[2] = {
        methylOnDimer->atom(0),
        dimer->atom(0)
    };
    analyzeAndChangeAtoms(atoms, 2);
    Finder::findAll(atoms, 2);
}

void MigrationThroughDimersRow::changeAtoms(Atom **atoms)
{
    Atom *a = atoms[0], *b = atoms[1];

    assert(a->is(26));
    assert(b->is(21));

    a->bondWith(b);

    if (a->is(13)) a->changeType(38);
    else if (a->is(27)) a->changeType(37);
    else a->changeType(10);

    b->changeType(23);
}
