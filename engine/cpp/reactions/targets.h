#ifndef TARGETS_H
#define TARGETS_H

#include "../atoms/atom.h"
#include "../tools/common.h"

namespace vd
{

template <class S, ushort TARGETS_NUM>
class Targets
{
    friend class Targets<S, TARGETS_NUM - 1>;
    friend class Targets<S, TARGETS_NUM + 1>;

    S *_targets[TARGETS_NUM];

public:
    Atom *anchor() const;

#ifdef PRINT
    void info(std::ostream &os);
#endif // PRINT

protected:
    Targets(S **targets);
    Targets(const Targets<S, TARGETS_NUM - 1> *parent, S *additional);
    Targets(const Targets<S, TARGETS_NUM + 1> *parent, S *removable);

    S *target(ushort index = 0) const;

    template <class R> void insert(R *reaction);
    template <class R> void erase(R *reaction);
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class S, ushort TARGETS_NUM>
Targets<S, TARGETS_NUM>::Targets(S **targets)
{
    for (ushort i = 0; i < TARGETS_NUM; ++i)
    {
        _targets[i] = targets[i];
    }
}

template <class S, ushort TARGETS_NUM>
Targets<S, TARGETS_NUM>::Targets(const Targets<S, TARGETS_NUM - 1> *parent, S *additional)
{
    for (ushort i = 0; i < TARGETS_NUM - 1; ++i)
    {
        _targets[i] = parent->_targets[i];
    }
    _targets[TARGETS_NUM - 1] = additional;
}

template <class S, ushort TARGETS_NUM>
Targets<S, TARGETS_NUM>::Targets(const Targets<S, TARGETS_NUM + 1> *parent, S *removable)
{
    for (ushort i = 0, j = 0; i < TARGETS_NUM + 1; ++i)
    {
        if (parent->_targets[i] != removable)
        {
            _targets[j++] = parent->_targets[i];
        }
    }
}

template <class S, ushort TARGETS_NUM>
Atom *Targets<S, TARGETS_NUM>::anchor() const
{
    Atom *atom = nullptr;
    for (int i = 0; i < TARGETS_NUM; ++i)
    {
        atom = _targets[i]->anchor();
        if (atom->lattice()) break;
    }
    assert(atom);
    return atom;
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

#ifdef PRINT
template <class S, ushort TARGETS_NUM>
void Targets<S, TARGETS_NUM>::info(std::ostream &os)
{
    for (int i = 0; i < TARGETS_NUM; ++i)
    {
        os << " ";
        assert(_targets[i]);
        if (_targets[i])
        {
            if (_targets[i]->anchor()->lattice())
            {
                os << _targets[i]->anchor()->lattice()->coords();
            }
            else
            {
                os << "amorph";
            }
        }
    }
}
#endif // PRINT

}

#endif // TARGETS_H
