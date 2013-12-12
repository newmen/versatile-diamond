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
    friend class ConcreteLateralReaction<LATERALS_NUM + 1>;

    WrappableReaction *_parent = nullptr;
    LateralSpec *_laterals[LATERALS_NUM];

public:
    void doIt() override { _parent->doIt(); }
    Atom *anchor() const override { return _parent->anchor(); }

    void store() override;
    void removeFrom(SpecificSpec *spec) override;
    void removeFrom(LateralSpec *spec) override;
    void removeFromAll() override;

    bool haveLateral(LateralSpec *spec) const;

#ifdef PRINT
    void info(std::ostream &os) override;
#endif // PRINT

protected:
    ConcreteLateralReaction(WrappableReaction *parent, LateralSpec *lateralSpec);
    ConcreteLateralReaction(WrappableReaction *parent, LateralSpec **lateralSpecs);
    ConcreteLateralReaction(ConcreteLateralReaction<LATERALS_NUM - 1> *lateralParent, LateralSpec *lateralSpec);

    WrappableReaction *parent() { return _parent; }

    void remove() override;
};

template <ushort LATERALS_NUM>
ConcreteLateralReaction<LATERALS_NUM>::ConcreteLateralReaction(WrappableReaction *parent, LateralSpec *lateralSpec) :
    ConcreteLateralReaction<LATERALS_NUM>(parent, &lateralSpec)
{
    static_assert(LATERALS_NUM == 1, "Wrong constructor for LateralReaction with one LateralSpec");
}

template <ushort LATERALS_NUM>
ConcreteLateralReaction<LATERALS_NUM>::ConcreteLateralReaction(WrappableReaction *parent, LateralSpec **lateralSpecs) :
    _parent(parent)
{
    for (uint i = 0; i < LATERALS_NUM; ++i)
    {
        assert(lateralSpecs[i]);
        _laterals[i] = lateralSpecs[i];
    }
}

template <ushort LATERALS_NUM>
ConcreteLateralReaction<LATERALS_NUM>::ConcreteLateralReaction(
        ConcreteLateralReaction<LATERALS_NUM - 1> *lateralParent, LateralSpec *lateralSpec) :
    _parent(lateralParent->_parent)
{
    for (uint i = 0; i < LATERALS_NUM - 1; ++i)
    {
        _laterals[i] = lateralParent->_laterals[i];
    }
    _laterals[LATERALS_NUM - 1] = lateralSpec;

    delete lateralParent;
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
void ConcreteLateralReaction<LATERALS_NUM>::removeFromAll()
{
    _parent->removeAsFromAll(this);

    for (uint i = 0; i < LATERALS_NUM; ++i)
    {
        _laterals[i]->unbindFrom(this);
    }
}

template <ushort LATERALS_NUM>
bool ConcreteLateralReaction<LATERALS_NUM>::haveLateral(LateralSpec *spec) const
{
    for (uint i = 0; i < LATERALS_NUM; ++i)
    {
        if (spec == _laterals[i])
        {
            return true;
        }
    }
    return false;
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
