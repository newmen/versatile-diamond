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

    cout << Dictionary::mc().totalRate() << endl;

    Atom *a = diamond->atom(int3(2, 2, 1)), *b = diamond->atom(int3(2, 3, 1));
    ReactionActivation raa(a);
    raa.doIt();

    ReactionActivation rab(b);
    rab.doIt();

    a->bondWith(b);

    a->changeType(6);
    b->changeType(6);

    a->findChildren();
    b->findChildren();

    cout << Dictionary::specsNum() << endl;
    assert(Dictionary::specsNum() == 101);

    cout << Dictionary::mc().totalRate() << endl;


    Dictionary::purge();
    delete diamond;
    return 0;
}
