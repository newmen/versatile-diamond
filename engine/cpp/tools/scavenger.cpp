#include "scavenger.h"

namespace vd
{

Scavenger::~Scavenger()
{
    clear();
}

void Scavenger::markAtom(Atom *atom)
{
    atom->prepareToRemove();
    AtomsCollector::store(atom);
}

void Scavenger::markSpec(BaseSpec *spec)
{
    SpecsCollector::store(spec);
}

void Scavenger::markReaction(SpecReaction *reaction)
{
    SpecReactionsCollector::store(reaction);
}

void Scavenger::markReaction(UbiquitousReaction *reaction)
{
    UbiquitousReactionsCollector::store(reaction);
}

void Scavenger::clear()
{
    deleteAndClear<UbiquitousReaction>();
    deleteAndClear<SpecReaction>();
    deleteAndClear<BaseSpec>();
    deleteAndClear<Atom>();
}

}
