#include <omp.h>
#include <vector>
#include <mc/common_mc_data.h>
#include <generations/builders/atom_builder.h>
#include <generations/reactions/ubiquitous/surface_activation.h>
#include <generations/reactions/ubiquitous/surface_deactivation.h>
using namespace vd;

#include "../support/open_diamond.h"

#include <iostream>
using namespace std;

void store(CommonMCData *mcData, Reaction *a, Reaction *b)
{
    if (omp_get_thread_num() == 0)
    {
        mcData->checkSame(a);
    }
    else if (omp_get_thread_num() == 1)
    {
        mcData->checkSame(b);
    }

#pragma omp barrier
}

void checkSame(CommonMCData *mcData, Reaction *a, Reaction *b)
{
#pragma omp parallel
    {
        store(mcData, a, b);

        if (omp_get_thread_num() == 0)
        {
            assert(!mcData->isSame());
        }
        else if (omp_get_thread_num() == 1)
        {
            assert(mcData->isSame());
        }

#pragma omp barrier

#pragma omp master
        {
            assert(mcData->hasSameSite());
        }
    }
}

void checkNotSame(CommonMCData *mcData, Reaction *a, Reaction *b)
{
#pragma omp parallel
    {
        store(mcData, a, b);

        if (omp_get_thread_num() == 0)
        {
            assert(!mcData->isSame());
        }
        else if (omp_get_thread_num() == 1)
        {
            assert(!mcData->isSame());
        }

#pragma omp barrier

#pragma omp master
        {
            assert(!mcData->hasSameSite());
        }
    }
}

int main()
{
    const dim3 &s = OpenDiamond::SIZES;
    CommonMCData mcData;

    std::vector<Atom *> atoms;
    OpenDiamond diamond;
    AtomBuilder builder;

    auto buildCd = [&atoms, &diamond, &builder](ushort type, ushort actives, int x, int y, int z)
    {
        Atom *atom = builder.buildCd(type, actives, &diamond, int3(x, y, z));
        atoms.push_back(atom);
        return atom;
    };

    Atom *c111 = buildCd(1, 1, 1, 1, 1);
    Atom *c211 = buildCd(1, 1, 2, 1, 1);
    Atom *c121 = buildCd(1, 1, 1, 2, 1);
    Atom *c991 = buildCd(1, 1, 9, 9, 1);
    Atom *cxy1 = buildCd(1, 1, s.x - 1, s.y - 1, 1);

    SurfaceActivation sa111(c111), sa211(c211), sa991(c991);
    SurfaceDeactivation sd111(c111), sd121(c121), sdxy1(cxy1);

    omp_set_num_threads(2);

    checkSame(&mcData, &sa111, &sa111);
    mcData.reset();

    checkSame(&mcData, &sa111, &sd111);
    mcData.reset();

    checkSame(&mcData, &sa211, &sd121);
    mcData.reset();

    // checkSame(&mcData, &sa111, &sdxy1);
    // mcData.reset();

    // checkNotSame(&mcData, &sa111, &sa991);
    // mcData.reset();

    for (Atom *atom : atoms) delete atom;
    return 0;
}