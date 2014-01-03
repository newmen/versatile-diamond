#include "dimer_crs_cli.h"
#include "../../reactions/typical/high_bridge_stand_to_dimer.h"

const ushort DimerCRsCLi::__indexes[2] = { 0, 3 };
const ushort DimerCRsCLi::__roles[2] = { 21, 20 };

void DimerCRsCLi::find(DimerCRs *parent)
{
    Atom *anchor = parent->atom(3);
    if (anchor->is(20))
    {
        if (!anchor->hasRole<DimerCRsCLi>(20))
        {
            create<DimerCRsCLi>(parent);
        }
    }
}

void DimerCRsCLi::findAllReactions()
{
    HighBridgeStandToDimer::find(this);
}
