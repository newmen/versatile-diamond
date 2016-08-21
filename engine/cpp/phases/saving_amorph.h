#ifndef SAVING_AMORPH_H
#define SAVING_AMORPH_H

#include "../atoms/saving_atom.h"
#include "templated_amorph.h"

namespace vd
{

class SavingAmorph : public TemplatedAmorph<SavingAtom>
{
public:
    SavingAmorph() = default;
};

}

#endif // SAVING_AMORPH_H
