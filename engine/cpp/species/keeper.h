#ifndef KEEPER_H
#define KEEPER_H

#include <vector>
#include "../tools/common.h"
#include "base_spec.h"

#include <omp.h>

namespace vd
{

template <ushort SPECIFIC_SPECS_NUM>
class Keeper
{
    std::vector<BaseSpec *> _newSpecs[SPECIFIC_SPECS_NUM];

public:
//    Keeper();

    template <ushort SST>
    void store(BaseSpec *specificSpec);

    void findAll();
    void clear();
};

template <ushort SPECIFIC_SPECS_NUM>
template <ushort SST>
void Keeper<SPECIFIC_SPECS_NUM>::store(vd::BaseSpec *specificSpec)
{
    static_assert(SST < SPECIFIC_SPECS_NUM, "Wrong specific spec ID");

#pragma omp critical
    {
        _newSpecs[SST].push_back(specificSpec);
    }
}

template <ushort SPECIFIC_SPECS_NUM>
void Keeper<SPECIFIC_SPECS_NUM>::clear()
{
    for (int i = 0; i < SPECIFIC_SPECS_NUM; ++i)
    {
        std::vector<BaseSpec *>().swap(_newSpecs[i]); // with clear capacity of vector
    }
}

// Must be used in omp parallel block of Finder
template <ushort SPECIFIC_SPECS_NUM>
void Keeper<SPECIFIC_SPECS_NUM>::findAll()
{
#pragma omp for
    for (int i = 0; i < SPECIFIC_SPECS_NUM; ++i)
    {
//#pragma omp parallel for
        for (int j = 0; j < _newSpecs[i].size(); ++j)
//        for (BaseSpec *spec : _newSpecs[i])
        {
            BaseSpec *spec = _newSpecs[i][j];
            spec->findChildren();
        }
    }
}

}

#endif // KEEPER_H
