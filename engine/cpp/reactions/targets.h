#ifndef TARGETS_H
#define TARGETS_H

#include "../atoms/atom.h"
#include "../tools/common.h"

namespace vd
{

template <class S, ushort TARGETS_NUM>
class Targets
{
    S *_targets[TARGETS_NUM];

public:
#if defined(PRINT) || defined(MC_PRINT)
    void info(IndentStream &os);
#endif // PRINT || MC_PRINT

protected:
    Targets(S **targets);

    inline S *target(ushort index = 0) const;

    template <class R> void insert(R *reaction);
    template <class R> void erase(R *reaction);
};

//////////////////////////////////////////////////////////////////////////////////////

template <class S, ushort TARGETS_NUM>
Targets<S, TARGETS_NUM>::Targets(S **targets)
{
    for (ushort i = 0; i < TARGETS_NUM; ++i)
    {
        _targets[i] = targets[i];
    }
}

template <class S, ushort TARGETS_NUM>
S *Targets<S, TARGETS_NUM>::target(ushort index) const
{
    assert(index < TARGETS_NUM);
    return _targets[index];
}

template <class S, ushort TARGETS_NUM>
template <class R>
void Targets<S, TARGETS_NUM>::insert(R *reaction)
{
    for (ushort i = 0; i < TARGETS_NUM; ++i)
    {
        _targets[i]->insertReaction(reaction);
    }
}

template <class S, ushort TARGETS_NUM>
template <class R>
void Targets<S, TARGETS_NUM>::erase(R *reaction)
{
    for (ushort i = 0; i < TARGETS_NUM; ++i)
    {
        _targets[i]->eraseReaction(reaction);
    }
}

#if defined(PRINT) || defined(MC_PRINT)
template <class S, ushort TARGETS_NUM>
void Targets<S, TARGETS_NUM>::info(IndentStream &os)
{
    for (int i = 0; i < TARGETS_NUM; ++i)
    {
        assert(_targets[i]);
        os << " " << _targets[i];
    }
}
#endif // PRINT || MC_PRINT

}

#endif // TARGETS_H
