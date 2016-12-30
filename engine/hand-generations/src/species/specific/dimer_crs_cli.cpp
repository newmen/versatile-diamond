#include "dimer_crs_cli.h"
#include "../../reactions/typical/high_bridge_stand_to_dimer.h"

template <> const ushort DimerCRsCLi::Base::__indexes[1] = { 0 };
template <> const ushort DimerCRsCLi::Base::__roles[1] = { 21 };

#if defined(PRINT) || defined(SPEC_PRINT) || defined(SERIALIZE)
const char *DimerCRsCLi::name() const
{
    static const char value[] = "dimer(cr: *, cl: i)";
    return value;
}
#endif // PRINT || SPEC_PRINT || SERIALIZE

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
