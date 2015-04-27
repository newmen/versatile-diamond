#ifndef SAVING_AMORPH_H
#define SAVING_AMORPH_H

#include "../atoms/saving_atom.h"
#include "../tools/common.h"
#include "templated_amorph.h"
#include "amorph.h"

namespace vd
{

class SavingAmorph : public TemplatedAmorph<SavingAtom>
{
public:
    SavingAmorph() = default;

private:
    SavingAmorph(const SavingAmorph &) = delete;
    SavingAmorph(SavingAmorph &&) = delete;
    SavingAmorph &operator = (const SavingAmorph &) = delete;
    SavingAmorph &operator = (SavingAmorph &&) = delete;
};

}

#endif // SAVING_AMORPH_H
