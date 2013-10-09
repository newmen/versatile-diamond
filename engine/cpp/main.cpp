#include "crystals/diamond.h"

int main()
{
    Crystal *crystal = new Diamond(dim3(10, 10, 3));
    crystal->initialize();

    delete crystal;

    return 0;
}
