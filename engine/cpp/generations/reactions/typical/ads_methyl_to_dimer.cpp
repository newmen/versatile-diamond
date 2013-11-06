#include "ads_methyl_to_dimer.h"
#include "../../builders/atom_builder.h"

#include <assert.h>

void AdsMethylToDimer::find(DimerCRs *target)
{
    const ushort indexes[1] = { 0 };
    const ushort types[1] = { 21 };

    MonoTypical::find<AdsMethylToDimer, 1>(target, indexes, types);
}

void AdsMethylToDimer::doIt()
{
    AtomBuilder builder;
    Atom *atoms[2] = { target()->atom(0), builder.buildC(25, 1) };
    Atom *a = atoms[0], *b = atoms[1];

    a->bondWith(b);

    assert(a->is(21));
    a->changeType(23);

    Handbook::amorph.insert(b);
    Finder::findAll(atoms, 2);
}
