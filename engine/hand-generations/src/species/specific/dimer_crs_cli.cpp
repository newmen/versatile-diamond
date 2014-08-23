#include "dimer_crs_cli.h"
#include "../../reactions/typical/high_bridge_stand_to_dimer.h"

const ushort DimerCRsCLi::Base::__indexes[1] = { 0 };
const ushort DimerCRsCLi::Base::__roles[1] = { 21 };

#ifdef PRINT
const char *DimerCRsCLi::name() const
{
    static const char value[] = "dimer(cr: *, cl: i)";
    return value;
}
#endif // PRINT

void DimerCRsCLi::find(DimerCRiCLi *parent)
{
    parent->eachSymmetry([](ParentSpec *specie) {
        Atom *anchor = specie->atom(0);
        if (anchor->is(21))
        {
            if (!anchor->hasRole(DIMER_CRs_CLi, 21))
            {
                create<DimerCRsCLi>(specie);
            }
        }
    });
}

void DimerCRsCLi::findAllTypicalReactions()
{
    HighBridgeStandToDimer::find(this);
}
