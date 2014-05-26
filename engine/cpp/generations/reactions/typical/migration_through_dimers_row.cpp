#include "migration_through_dimers_row.h"

const char MigrationThroughDimersRow::__name[] = "migration through dimers chain";
const double MigrationThroughDimersRow::RATE = 2.4e8 * std::exp(-30e3 / (1.98 * Env::T));

void MigrationThroughDimersRow::find(MethylOnDimerCMsiu *target)
{
    Atom *anchor = target->atom(1);
    eachNeighbour(anchor, &Diamond::cross_100, [target](Atom *neighbour) {
        if (neighbour->is(21))
        {
            auto neighbourSpec = neighbour->specByRole<DimerCRs>(21);
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
    Atom *anchor = target->anchor();
    eachNeighbour(anchor, &Diamond::cross_100, [target](Atom *neighbour) {
        if (neighbour->is(23))
        {
            auto neighbourSpec = neighbour->specByRole<MethylOnDimerCMsiu>(23);
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
    Atom *a = atoms[0], *b = atoms[1];

    assert(a->is(26));
    assert(b->is(21));

    a->bondWith(b);

    if (a->is(13)) a->changeType(38);
    else if (a->is(27)) a->changeType(37);
    else a->changeType(10);

    Finder::findAll(atoms, 2);
}
