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
};

}

#endif // AMORPH_H
