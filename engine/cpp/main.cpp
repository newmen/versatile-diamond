#include "generations/crystals/diamond.h"

#include <iostream>
using namespace std;

int main()
{
    Crystal *crystal = new Diamond(dim3(3, 3, 3));
    crystal->initialize();

    cout << "HELLO" << endl;
    cout << crystal->countAtoms() << endl;
    cout << "BUY" << endl;

    delete crystal;

    return 0;
}
