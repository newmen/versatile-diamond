#include "reaction_activation.h"
#include "../../dictionary.h"
#include "../../recipes/reactions/ubiquitous/reaction_activation_recipe.h"

ReactionActivation::ReactionActivation(Atom *target) : _target(target)
{
}

void ReactionActivation::doIt()
{
    short toType = Dictionary::hToActives(_target->type());
    assert(toType != -1);

    _target->activate();
    _target->changeType(toType);

    ReactionActivationRecipe rar;
    short dn = rar.delta(_target);
    assert(dn < 0);
    Dictionary::mc().removeActivations(this, -dn);

    _target->findChildren();
}
