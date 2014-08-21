#include "methyl_on_111_cmsiu.h"
#include "../../reactions/typical/migration_down_at_dimer_from_111.h"
#include "methyl_on_111_cmssiu.h"

const ushort MethylOn111CMsiu::Base::__indexes[1] = { 0 };
const ushort MethylOn111CMsiu::Base::__roles[1] = { 26 };

#ifdef PRINT
const char *MethylOn111CMsiu::name() const
{
    static const char value[] = "methyl_on_111(cm: *, cm: i, cm: u)";
    return value;
}
#endif // PRINT

void MethylOn111CMsiu::find(MethylOn111CMiu *parent)
{
    Atom *anchor = parent->atom(0);
    if (anchor->is(26))
    {
        if (!anchor->checkAndFind(METHYL_ON_111_CMsiu, 26))
        {
            create<MethylOn111CMsiu>(parent);
        }
    }
}

void MethylOn111CMsiu::findAllChildren()
{
    MethylOn111CMssiu::find(this);
}

void MethylOn111CMsiu::findAllTypicalReactions()
{
    MigrationDownAtDimerFrom111::find(this);
}
