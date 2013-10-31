#ifndef AMORPH_H
#define AMORPH_H

#include <unordered_set>
#include "phase.h"

namespace vd
{

class Amorph : public Phase
{
    std::unordered_set<Atom *> _atoms;

public:
    ~Amorph();

    void insert(Atom *atom);
    void erase(Atom *atom) override;
};

}

#endif // AMORPH_H
