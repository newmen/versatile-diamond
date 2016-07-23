#include "dimer_cri_cli.h"
#include "dimer_crs_cli.h"
#include "../../reactions/central/dimer_drop.h"

void DimerCRiCLi::find(Dimer *parent)
{
    Atom *anchors[2] = { parent->atom(0), parent->atom(3) };

    if (anchors[0]->is(20) && anchors[1]->is(20))
    {
        if (!anchors[0]->checkAndFind(DIMER_CRi_CLi, 20) && !anchors[1]->checkAndFind(DIMER_CRi_CLi, 20))
        {
            create<DimerCRiCLi>(parent);
        }
    }
}

void DimerCRiCLi::findAllChildren()
{
    DimerCRsCLi::find(this);
}

void DimerCRiCLi::findAllTypicalReactions()
{
    DimerDrop::find(this);
}
