#include "lateral_spec.h"
#include "../reactions/lateral_reaction.h"

namespace vd
{

void LateralSpec::remove()
{
    eachDupReaction([this](LateralReaction *reaction) {
        reaction->unconcretizeBy(this);
    });
}

}
