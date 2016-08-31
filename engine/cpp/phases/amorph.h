#ifndef AMORPH_H
#define AMORPH_H

#include "../atoms/atom.h"
#include "templated_amorph.h"

namespace vd
{

class Amorph : public TemplatedAmorph<Atom>
{
public:
    void erase(Atom *atom);

protected:
    Amorph() = default;
};

}

#endif // AMORPH_H
