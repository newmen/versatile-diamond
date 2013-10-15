#include <generations/dictionary.h>
#include <generations/crystals/diamond.h>
using namespace vd;

#include "../support/open_diamond.h"

#include <iostream>
using namespace std;

int main(int argc, char const *argv[])
{
    Diamond *diamond = new OpenDiamond(2);
    diamond->initialize();

    assert(Dictionary::specsNum() == 100);
    assert(Dictionary::mc().totalRate() == 720000);

    Atom *a = diamond->atom(int3(2, 2, 1)), *b = diamond->atom(int3(2, 3, 1));
    ReactionActivation raa(a);
    raa.doIt();

    ReactionActivation rab(b);
    rab.doIt();

    a->bondWith(b);

#pragma omp parallel
   {
#pragma omp sections
       {
#pragma omp section
            a->changeType(6);
#pragma omp section
            b->changeType(6);
       }

#pragma omp sections
       {
#pragma omp section
            a->findChildren();
#pragma omp section
            b->findChildren();
       }
   }

    assert(Dictionary::specsNum() == 101);
    assert(Dictionary::mc().totalRate() == 712800);

    Dictionary::purge();
    delete diamond;
    return 0;
}
