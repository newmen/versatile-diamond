#ifndef KEEPER_H
#define KEEPER_H

#include <vector>
#include "../tools/collector.h"
#include "specific_spec.h"

namespace vd
{

template <ushort SPECIFIC_SPECS_NUM>
class Keeper : public Collector<SpecificSpec, SPECIFIC_SPECS_NUM>
{
public:
    void findReactions();
};

// Must be used in omp parallel block of Finder
template <ushort SPECIFIC_SPECS_NUM>
void Keeper<SPECIFIC_SPECS_NUM>::findReactions()
{
    Collector<SpecificSpec, SPECIFIC_SPECS_NUM>::each([](std::vector<SpecificSpec *> &specs) {
        for (int i = 0; i < specs.size(); ++i)
        {
            SpecificSpec *spec = specs[i];
            spec->findReactions();
        }
    });
}

}

#endif // KEEPER_H
