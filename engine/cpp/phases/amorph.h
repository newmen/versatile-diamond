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

private:
    Amorph(const Amorph &) = delete;
    Amorph(Amorph &&) = delete;
    Amorph &operator = (const Amorph &) = delete;
    Amorph &operator = (Amorph &&) = delete;
};

}

#endif // AMORPH_H
