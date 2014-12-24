#ifndef AMORPH_H
#define AMORPH_H

#include <algorithm>
#include <unordered_set>
#include "../atoms/atom.h"
#include "../tools/common.h"

namespace vd
{

class Amorph
{
    typedef std::unordered_set<Atom *> Atoms;
    Atoms _atoms;

public:
    Amorph() = default;
    virtual ~Amorph();

    void insert(Atom *atom);
    void erase(Atom *atom);

    uint countAtoms() const;
    template <class L> void eachAtom(const L &lambda) const;

protected:
    Atoms &atoms() { return _atoms; }

private:
    Amorph(const Amorph &) = delete;
    Amorph(Amorph &&) = delete;
    Amorph &operator = (const Amorph &) = delete;
    Amorph &operator = (Amorph &&) = delete;
};

//////////////////////////////////////////////////////////////////////////////////////

template <class L>
void Amorph::eachAtom(const L &lambda) const
{
    std::for_each(_atoms.cbegin(), _atoms.cend(), lambda);
}

}

#endif // AMORPH_H
