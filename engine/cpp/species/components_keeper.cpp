#include "components_keeper.h"

namespace vd
{

void ComponentsKeeper::findComplexSpecies()
{
    ParentType::each([](ComponentSpec *spec) {
        spec->findAllComplexes();
    });
}

}
