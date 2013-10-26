#ifndef KEEPER_H
#define KEEPER_H

#include <vector>
#include "../tools/collector.h"
#include "base_spec.h"

#include <omp.h>

namespace vd
{

template <ushort SPECIFIC_SPECS_NUM>
class Keeper : public Collector<BaseSpec, SPECIFIC_SPECS_NUM>
{
public:
    void findAll();
};

// Must be used in omp parallel block of Finder
template <ushort SPECIFIC_SPECS_NUM>
void Keeper<SPECIFIC_SPECS_NUM>::findAll()
{
    Collector<BaseSpec, SPECIFIC_SPECS_NUM>::ompEach([](std::vector<BaseSpec *> &specs) {
//#pragma omp parallel for
        for (int i = 0; i < specs.size(); ++i)
        {
            BaseSpec *spec = specs[i];
            spec->findChildren();
        }
    });
}

}

#endif // KEEPER_H
