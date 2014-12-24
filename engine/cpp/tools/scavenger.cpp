#include "scavenger.h"

namespace vd
{

Scavenger::~Scavenger()
{
    clear();
}

void Scavenger::markAtom(Atom *atom)
{
    AtomsCollector::store(atom);
}

void Scavenger::markSpec(BaseSpec *spec)
{
    SpecsCollector::store(spec);
}

void Scavenger::markReaction(SpecReaction *reaction)
{
    ReactionsCollector::store(reaction);
}

void Scavenger::clear()
{
    deleteAndClear<Atom>();
    deleteAndClear<BaseSpec>();
    deleteAndClear<SpecReaction>();
}

}
