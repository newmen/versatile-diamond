#include "lateral_reaction.h"
#include "central_reaction.h"

namespace vd
{

LateralReaction::LateralReaction(CentralReaction *parent) : _parent(parent)
{
}

void LateralReaction::doIt()
{
    parent()->doIt();
}

void LateralReaction::store()
{
    SpecReaction::store();
    insertToTargets(this);
}

void LateralReaction::remove()
{
    eraseFromTargets(this);
    SpecReaction::remove();
}

void LateralReaction::insertToParentTargets()
{
    parent()->insertToTargets(this);
}

void LateralReaction::eraseFromParentTargets()
{
    parent()->eraseFromTargets(this);
}

}
