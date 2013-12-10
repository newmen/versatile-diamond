#include "specific_reactant.h"

namespace vd
{

void SpecificReactant::remove()
{
    RemovableReactant::remove();
    SpecificSpec::remove();
}

}
