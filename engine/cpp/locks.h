#ifndef LOCKS_H
#define LOCKS_H

#include <unordered_map>
#include <omp.h>

#include <assert.h>

namespace vd
{

class Locks
{
    std::unordered_map<void *, ushort> _ns;
    std::unordered_map<void *, omp_lock_t> _locks;
    omp_lock_t _mapLock;

    static Locks __locks;

public:
    static Locks *instance();

    Locks();
    ~Locks();

    template <class L>
    void lock(void *data, const L &lambda);
};

template <class L>
void Locks::lock(void *data, const L &lambda)
{
    assert(data);

    omp_set_lock(&_mapLock);
#pragma omp flush(_locks, _ns)
    if (_locks.find(data) == _locks.end())
    {
        omp_init_lock(&_locks[data]);
        _ns[data] = 0;
    }
    omp_lock_t *curr = &_locks[data];
    ushort &ns = _ns[data];
    ++ns;
    omp_unset_lock(&_mapLock);

    omp_set_lock(curr);
    lambda();
    omp_unset_lock(curr);

    omp_set_lock(&_mapLock);
#pragma omp flush(ns)
    if (--ns == 0)
    {
        omp_destroy_lock(curr);
#pragma omp flush(_locks, _ns)
        _locks.erase(data);
        _ns.erase(data);
    }
    omp_unset_lock(&_mapLock);
}

}

#endif // LOCKS_H
