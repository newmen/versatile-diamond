#include "common_mc_data.h"
#include <algorithm>

#ifdef PARALLEL
#include <omp.h>
#endif // PARALLEL

#include <iostream>

namespace vd
{

CommonMCData::CommonMCData()
{
    reset();
}

bool CommonMCData::isSame()
{
#ifdef PARALLEL
    int ct = omp_get_thread_num();
#else
    int ct = 0;
#endif // PARALLEL

    if (_sames[ct]) _sameSite = true;
    return _sames[ct];
}

void CommonMCData::checkSame(Reaction *reaction)
{
#ifdef PARALLEL
    int ct = omp_get_thread_num();
#else
    int ct = 0;
#endif // PARALLEL

    _reactions[ct] = reaction;

#ifdef PARALLEL
#pragma omp barrier
#endif // PARALLEL

    Atom *anchor = reaction->anchor();
    for (int i = 0; i < THREADS_NUM; ++i)
    {
        if (i == ct || !_reactions[i]) continue;
        if (reaction == _reactions[i])
        {
            updateSame(ct, i);
        }

        Atom *atom = _reactions[i]->anchor();
        if (atom == anchor || isNear(atom, anchor))
        {
            updateSame(ct, i);
        }
    }
}

void CommonMCData::reset()
{
    _wasntFound = false;
    _sameSite = false;
    for (int i = 0; i < THREADS_NUM; ++i)
    {
        _reactions[i] = nullptr;
        _sames[i] = false;
    }
}

void CommonMCData::updateSame(int currentThread, int anotherThread)
{
    if (currentThread > anotherThread)
    {
        _sames[currentThread] = true;
    }
}

bool CommonMCData::isNear(Atom *a, Atom *b) const
{
    if (!(a->lattice() && b->lattice() && a->lattice()->crystal() == b->lattice()->crystal())) return false;

    const dim3 &sizes = a->lattice()->crystal()->sizes();
    const int3 &ac = a->lattice()->coords();
    const int3 &bc = b->lattice()->coords();

    return isNearByOneAxis(sizes.x, ac.x, bc.x) && isNearByOneAxis(sizes.y, ac.y, bc.y) &&
            std::abs(ac.z - bc.z) < MIN_DISTANCE;
}

bool CommonMCData::isNearByOneAxis(uint max, int v, int w) const
{
    return std::abs(v - w) < MIN_DISTANCE ||
            max - std::max(v, w) + std::min(v, w) < MIN_DISTANCE;
}

}
