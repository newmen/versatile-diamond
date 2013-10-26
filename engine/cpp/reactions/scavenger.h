#ifndef SCAVENGER_H
#define SCAVENGER_H

#include "../tools/collector.h"
#include "../reactions/spec_reaction.h"

namespace vd
{

template <ushort TYPICAL_REACTIONS_NUM>
class Scavenger : public Collector<SpecReaction, TYPICAL_REACTIONS_NUM>
{
public:
    void clear();
};

template <ushort TYPICAL_REACTIONS_NUM>
void Scavenger<TYPICAL_REACTIONS_NUM>::clear()
{
    Collector<SpecReaction, TYPICAL_REACTIONS_NUM>::each([](std::vector<SpecReaction *> &reactions) {
#ifdef PARALLEL
//#pragma omp parallel for
#endif // PARALLEL
        for (int i = 0; i < reactions.size(); ++i)
        {
            delete reactions[i];
        }
    });

    Collector<SpecReaction, TYPICAL_REACTIONS_NUM>::clear();
}

}

#endif // SCAVENGER_H
