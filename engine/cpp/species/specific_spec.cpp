#include "specific_spec.h"

namespace vd
{

void SpecificSpec::remove()
{
    eachDupReaction([](SpecReaction *reaction) {
        reaction->remove();
    });
}

}
