#include "lateral_spec.h"
#include "../reactions/lateral_reaction.h"

namespace vd
{

void LateralSpec::findLateralReactions()
{
    findAllLateralReactions();
    setNotNew();
}

void LateralSpec::unconcretizeReactions()
{
    eachDupReaction([this](LateralReaction *reaction) {
        reaction->unconcretizeBy(this);
    });
}

}
