#include "methyl_on_111_cmiu.h"
#include "../../reactions/typical/des_methyl_from_111.h"
#include "methyl_on_111_cmsiu.h"

const ushort MethylOn111CMiu::Base::__indexes[2] = { 1, 0 };
const ushort MethylOn111CMiu::Base::__roles[2] = { 33, 25 };

#ifdef PRINT
const char *MethylOn111CMiu::name() const
{
    static const char value[] = "methyl_on_111(cm: i, cm: u)";
    return value;
}
#endif // PRINT

void MethylOn111CMiu::find(MethylOnBridge *parent)
{
    Atom *anchors[2] = { parent->atom(0), parent->atom(1) };
    if (anchors[0]->is(25) && anchors[1]->is(33))
    {
        if (!anchors[0]->checkAndFind(METHYL_ON_111_CMiu, 25) &&
                !anchors[1]->checkAndFind(METHYL_ON_111_CMiu, 33))
        {
            create<MethylOn111CMiu>(parent);
        }
    }
}

void MethylOn111CMiu::findAllChildren()
{
    MethylOn111CMsiu::find(this);
}

void MethylOn111CMiu::findAllTypicalReactions()
{
    DesMethylFrom111::find(this);
}

