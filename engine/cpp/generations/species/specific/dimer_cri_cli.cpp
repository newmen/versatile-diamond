#include "dimer_cri_cli.h"
#include "../../reactions/typical/dimer_drop.h"

const ushort DimerCRiCLi::__indexes[2] = { 0, 3 };
const ushort DimerCRiCLi::__roles[2] = { 20, 20 };

#ifdef PRINT
const char *DimerCRiCLi::name() const
{
    static const char value[] = "dimer(cr: i, cl: i)";
    return value;
}
#endif // PRINT

void DimerCRiCLi::find(Dimer *parent)
{
    Atom *anchors[2] = { parent->atom(0), parent->atom(3) };

    if (anchors[0]->is(20) && anchors[1]->is(20))
    {
        if (!anchors[0]->hasRole(DIMER_CRi_CLi, 20) && !anchors[1]->hasRole(DIMER_CRi_CLi, 20))
        {
            create<DimerCRiCLi>(parent);
        }
    }
}

void DimerCRiCLi::findAllTypicalReactions()
{
    DimerDrop::find(this);
}
