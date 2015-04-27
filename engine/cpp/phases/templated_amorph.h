#ifndef TEMPLATED_AMORPH_H
#define TEMPLATED_AMORPH_H

#include <algorithm>
#include <unordered_set>
#include "../tools/common.h"

namespace vd
{

template <class A>
class TemplatedAmorph
{
    typedef std::unordered_set<A *> Atoms;
    Atoms _atoms;

public:
    virtual ~TemplatedAmorph();

    void insert(A *atom);

    template <class L> void eachAtom(const L &lambda) const;

    uint countAtoms() const;

protected:
    TemplatedAmorph() = default;

    Atoms &atoms() { return _atoms; }

private:
    TemplatedAmorph(const TemplatedAmorph &) = delete;
    TemplatedAmorph(TemplatedAmorph &&) = delete;
    TemplatedAmorph &operator = (const TemplatedAmorph &) = delete;
    TemplatedAmorph &operator = (TemplatedAmorph &&) = delete;
};

//////////////////////////////////////////////////////////////////////////////////////

template <class A>
TemplatedAmorph<A>::~TemplatedAmorph()
{
    for (A *atom : _atoms)
    {
        delete atom;
    }
}

template <class A>
void TemplatedAmorph<A>::insert(A *atom)
{
    assert(atom);
    assert(!atom->lattice());

    _atoms.insert(atom);
}

template <class A>
template <class L>
void TemplatedAmorph<A>::eachAtom(const L &lambda) const
{
    std::for_each(_atoms.cbegin(), _atoms.cend(), lambda);
}

template <class A>
uint TemplatedAmorph<A>::countAtoms() const
{
    return _atoms.size();
}

}

#endif // TEMPLATED_AMORPH_H

