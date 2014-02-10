#include "methyl_on_111_cmssiu.h"
#include "../../reactions/typical/migration_down_in_gap_from_111.h"

const ushort MethylOn111CMssiu::__indexes[1] = { 0 };
const ushort MethylOn111CMssiu::__roles[1] = { 27 };

#ifdef PRINT
const char *MethylOn111CMssiu::name() const
{
    static const char value[] = "methyl_on_111(cm: **, cm: i, cm: u)";
    return value;
}
#endif // PRINT

void MethylOn111CMssiu::find(MethylOn111CMsiu *parent)
{
    Atom *anchor = parent->atom(0);
    if (anchor->is(27))
    {
        if (!anchor->hasRole(METHYL_ON_111_CMssiu, 27))
        {
            create<MethylOn111CMssiu>(parent);
        }
    }
}

void MethylOn111CMssiu::findAllTypicalReactions()
{
    MigrationDownInGapFrom111::find(this);
}
