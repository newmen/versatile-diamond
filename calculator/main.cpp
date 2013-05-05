#include "generation/defaultcompositionbuilder.h"
#include "crystals/diamond.h"

int main()
{
    CompositionBuilder *builder = new DefaultCompositionBuilder;
    Crystal *crystal = new Diamond(dim3(10, 10, 3), builder);
    crystal->bondTogether();

    delete crystal;
    delete builder;

    return 0;
}
