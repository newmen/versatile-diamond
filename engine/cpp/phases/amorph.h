#ifndef AMORPH_H
#define AMORPH_H

#include <unordered_set>
#include "../tools/common.h"
#include "phase.h"

namespace vd
{

class Amorph : public Phase
{
    typedef std::unordered_set<Atom *> Atoms;
    Atoms _atoms;

public:
    ~Amorph();

    void insert(Atom *atom);
    void erase(Atom *atom) override;

    uint countAtoms() const;

protected:
    Atoms &atoms() { return _atoms; }
};

}

#endif // AMORPH_H
