#include "generations/atoms/c.h"
#include "generations/crystals/diamond.h"

#include <iostream>
using namespace std;

int main()
{
    Crystal *crystal = new Diamond(dim3(3, 3, 5));
    crystal->initialize();

    crystal->insert(new C(0, 0, (Lattice *)0), int3(1, 1, 2));

    cout << crystal->countAtoms() << endl;

    delete crystal;

    return 0;
}
