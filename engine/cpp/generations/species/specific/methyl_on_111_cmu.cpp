#include "methyl_on_111_cmu.h"
#include "../../reactions/typical/des_methyl_from_111.h"
#include "methyl_on_111_cmsu.h"

const ushort MethylOn111CMu::__indexes[2] = { 1, 0 };
const ushort MethylOn111CMu::__roles[2] = { 33, 25 };

void MethylOn111CMu::find(MethylOnBridge *parent)
{
    Atom *anchors[2] = { parent->atom(0), parent->atom(1) };
    if (anchors[0]->is(25) && anchors[1]->is(33))
    {
        if (!anchors[0]->hasRole(METHYL_ON_111_CMu, 25) && !anchors[1]->hasRole(METHYL_ON_111_CMu, 33))
        {
            create<MethylOn111CMu>(parent);
        }
    }
}

void MethylOn111CMu::findAllChildren()
{
    MethylOn111CMsu::find(this);
}

void MethylOn111CMu::findAllTypicalReactions()
{
    DesMethylFrom111::find(this);
}

