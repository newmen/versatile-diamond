#include "dimer_crs_cli.h"
#include "../../reactions/typical/high_bridge_stand_to_dimer.h"

const ushort DimerCRsCLi::Base::__indexes[2] = { 0, 3 };
const ushort DimerCRsCLi::Base::__roles[2] = { 21, 20 };

#ifdef PRINT
const char *DimerCRsCLi::name() const
{
    static const char value[] = "dimer(cr: *, cl: i)";
    return value;
}
#endif // PRINT

void DimerCRsCLi::find(DimerCRs *parent)
{
    Atom *anchor = parent->atom(3);
    if (anchor->is(20))
    {
        if (!anchor->hasRole(DIMER_CRs_CLi, 20))
        {
            create<DimerCRsCLi>(parent);
        }
    }
}

void DimerCRsCLi::findAllTypicalReactions()
{
    HighBridgeStandToDimer::find(this);
}
