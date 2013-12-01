#ifndef AMORPH_H
#define AMORPH_H

#include <unordered_set>
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

protected:
    Atoms &atoms() { return _atoms; }
};

}

#endif // AMORPH_H
