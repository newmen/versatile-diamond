#ifndef CONCRETE_LATERAL_REACTION_H
#define CONCRETE_LATERAL_REACTION_H

#include "../species/lateral_spec.h"
#include "lateral_reaction.h"
#include "wrappable_reaction.h"

#ifdef PRINT
#include <iostream>
#include "../tools/debug_print.h"
#endif // PRINT

namespace vd
{

template <ushort LATERALS_NUM>
class ConcreteLateralReaction : public LateralReaction
{
    WrappableReaction *_parent = nullptr;
    LateralSpec *_laterals[LATERALS_NUM];

public:
    ~ConcreteLateralReaction() { delete _parent; }

    void doIt() override { _parent->doIt(); }
    Atom *anchor() const override { return _parent->anchor(); }

    void store() override;
    void removeFrom(SpecificSpec *spec) override;
    void removeFrom(LateralSpec *spec) override;

#ifdef PRINT
    void info(std::ostream &os) override;
#endif // PRINT

protected:
    ConcreteLateralReaction(WrappableReaction *parent, LateralSpec *lateral);
    ConcreteLateralReaction(WrappableReaction *parent, LateralSpec **laterals);

    void remove() override;
};

template <ushort LATERALS_NUM>
ConcreteLateralReaction<LATERALS_NUM>::ConcreteLateralReaction(WrappableReaction *parent, LateralSpec *lateral) :
    ConcreteLateralReaction<LATERALS_NUM>(parent, &lateral)
{
    static_assert(LATERALS_NUM == 1, "Wrong constructor for LateralReaction with one LateralSpec");
}

template <ushort LATERALS_NUM>
ConcreteLateralReaction<LATERALS_NUM>::ConcreteLateralReaction(WrappableReaction *parent, LateralSpec **laterals) :
    _parent(parent)
{
    for (uint i = 0; i < LATERALS_NUM; ++i)
    {
        assert(laterals[i]);
        _laterals[i] = laterals[i];
    }
}

template <ushort LATERALS_NUM>
void ConcreteLateralReaction<LATERALS_NUM>::store()
{
    _parent->storeAs(this);

    for (uint i = 0; i < LATERALS_NUM; ++i)
    {
        _laterals[i]->usedIn(this);
    }
}

template <ushort LATERALS_NUM>
void ConcreteLateralReaction<LATERALS_NUM>::removeFrom(SpecificSpec *spec)
{
    if (_parent->removeAsFrom(this, spec))
    {
        remove();
    }
}

template <ushort LATERALS_NUM>
void ConcreteLateralReaction<LATERALS_NUM>::removeFrom(LateralSpec *spec)
{
#ifdef DEBUG
    bool isFound = false;
#endif // DEBUG

    for (uint i = 0; i < LATERALS_NUM; ++i)
    {
        if (spec == _laterals[i])
        {
#ifdef DEBUG
            isFound = true;
#endif // DEBUG

            _laterals[i]->unbindFrom(this);
            _laterals[i] = nullptr;

            break;
        }
    }

    assert(isFound);
}

template <ushort LATERALS_NUM>
void ConcreteLateralReaction<LATERALS_NUM>::remove()
{
    for (uint i = 0; i < LATERALS_NUM; ++i)
    {
        if (_laterals[i])
        {
            _laterals[i]->unbindFrom(this);
        }
    }
}

#ifdef PRINT
template <ushort LATERALS_NUM>
void ConcreteLateralReaction<LATERALS_NUM>::info(std::ostream &os)
{
    os << "LateralReaction -> ";
    _parent->info(os);

    os << "     +++>>>     ";
    for (uint i = 0; i < LATERALS_NUM; ++i)
    {
        if (_laterals[i])
        {
            _laterals[i]->info(os);
        }
        else
        {
            os << "zerofied";
        }
        os << " /// ";
    }
}
#endif // PRINT

}

#endif // CONCRETE_LATERAL_REACTION_H
