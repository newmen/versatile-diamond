#include "generations/dictionary.h"
#include "generations/crystals/diamond.h"
using namespace vd;

#include "spec/support/open_diamond.h"

#include <omp.h>
#include <iostream>
using namespace std;

int main(int argc, char const *argv[])
{
    Diamond *diamond = new OpenDiamond(2);
    diamond->initialize();

cout << Dictionary::specsNum() << endl;
    assert(Dictionary::specsNum() == 100);

    Atom *a = diamond->atom(int3(2, 2, 1)), *b = diamond->atom(int3(2, 3, 1));
    a->activate();
    b->activate();

    a->bondWith(b);

//#pragma omp parallel
//    {
//#pragma omp sections
//        {
//#pragma omp section
            a->changeType(6);
//#pragma omp section
            b->changeType(6);
//        }

//#pragma omp sections
//        {
//#pragma omp section
            a->findChildren();
//#pragma omp section
            b->findChildren();
//        }
//    }

cout << Dictionary::specsNum() << endl;
    assert(Dictionary::specsNum() == 101);

    Dictionary::purge();
    delete diamond;
    return 0;
}
