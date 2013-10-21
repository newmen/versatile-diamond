#include "mc.h"

namespace vd
{

MC::MC()
{
}

template <class R>
void MC::add(std::unordered_map<R *, uint> *m, std::vector<R *> *v, R *r)
{

#pragma omp atomic
    _totalRate += r->rate();
}

template <class R>
void MC::remove(std::unordered_map<R *, uint> *m, std::vector<R *> *v, R *r)
{

#pragma omp atomic
    _totalRate -= r->rate();
}

template <class R>
void MC::addUb(std::unordered_multimap<R *, uint> *m, std::vector<R *> *v, R *r, uint n)
{
#pragma omp critical
    {
        for (int i = 0; i < n; ++i)
        {
            v->push_back(r);
            (*m)[r] = v->size() - 1;
        }
    }

#pragma omp atomic
    _totalRate += r->rate() * n;
}

template <class R>
void MC::removeUb(std::unordered_multimap<R *, uint> *m, std::vector<R *> *v, R *r, uint n)
{
#pragma omp critical
    {
        for (int i = 0; i < n; ++i)
        {
            assert(m->find(r) != m->end());
            R *last = *v->rbegin();
            v->pop_back();

            auto it = v->begin() + (*m)[r];
            delete *it;
            *it = last;
        }
    }

#pragma omp atomic
    _totalRate -= r->rate() * n;
}

}
