#ifndef AMORPH_H
#define AMORPH_H

#include <unordered_set>
#include "phase.h"

namespace vd
{

class Amorph : public Phase
{
public:
    typedef std::unordered_set<Atom *> Atoms;

    Amorph();

    void insert(Atom *atom);
    void erase(Atom *atom) override;

private:
    Atoms _atoms;
};

}

#endif // AMORPH_H
