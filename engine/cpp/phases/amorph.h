#ifndef AMORPH_H
#define AMORPH_H

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

    void setUnvisited();
#ifndef NDEBUG
    void checkAllVisited();
#endif // NDEBUG

protected:
    Atoms &atoms() { return _atoms; }

private:
    Amorph(const Amorph &) = delete;
    Amorph(Amorph &&) = delete;
    Amorph &operator = (const Amorph &) = delete;
    Amorph &operator = (Amorph &&) = delete;
};

}

#endif // AMORPH_H
