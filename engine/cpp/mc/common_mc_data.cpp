#include "common_mc_data.h"
#include <algorithm>
#include <iostream>

#ifdef PARALLEL
#include <omp.h>
#endif // PARALLEL

namespace vd
{

CommonMCData::CommonMCData()
{
    reset();
}

CommonMCData::~CommonMCData()
{
    delete _counter;
}

double CommonMCData::rand(double maxValue)
{
    return _generators[currThreadNum()].rand(maxValue);
}

void CommonMCData::makeCounter(uint reactionsNum)
{
    _counter = new Counter(reactionsNum);
}

bool CommonMCData::isSame()
{
    int ct = currThreadNum();
    if (_sames[ct])
    {
#ifdef PARALLEL
#pragma omp critical
#endif // PARALLEL
        _sameSite = true;
    }
    return _sames[ct];
}

void CommonMCData::store(Reaction *reaction)
{
    int ct = currThreadNum();
    _reactions[ct] = reaction;
}

void CommonMCData::checkSame()
{
    int ct = currThreadNum();
    Reaction *reaction = _reactions[ct];
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

int CommonMCData::currThreadNum() const
{
#ifdef PARALLEL
    return omp_get_thread_num();
#else
    return 0;
#endif // PARALLEL
}

void CommonMCData::updateSame(int currentThread, int anotherThread)
{
    if (_reactions[currentThread]->rate() < _reactions[anotherThread]->rate())
    {
        setSame(currentThread);
    }
    else
    {
        setSame(anotherThread);
    }
}

void CommonMCData::setSame(uint threadId)
{
#ifdef PARALLEL
#pragma omp critical
#endif // PARALLEL
    _sames[threadId] = true;
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
