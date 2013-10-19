#include <generations/handbook.h>
#include <generations/crystals/diamond.h>
using namespace vd;

#include "../support/open_diamond.h"

#include <iostream>
using namespace std;

int main(int argc, char const *argv[])
{
    Diamond *diamond = new OpenDiamond(2);
    diamond->initialize();

    assert(Handbook::mc().totalRate() == 720000);

    Atom *a = diamond->atom(int3(2, 2, 1)), *b = diamond->atom(int3(2, 3, 1));
    ReactionActivation raa(a);
    raa.doIt();
    assert(Handbook::mc().totalRate() == 718400);

    ReactionActivation rab(b);
    rab.doIt();
    assert(Handbook::mc().totalRate() == 716800);

    a->bondWith(b);

#pragma omp parallel
   {
#pragma omp sections
       {
#pragma omp section
            a->changeType(22);
#pragma omp section
            b->changeType(22);
       }

#pragma omp sections
       {
#pragma omp section
            a->findChildren();
#pragma omp section
            b->findChildren();
       }
   }

    Atom *c = diamond->atom(int3(4, 2, 1));
    ReactionActivation rac(c);
    rac.doIt();
    rac.doIt();

    assert(Handbook::mc().totalRate() == 713600);

    delete diamond;
    return 0;
}
