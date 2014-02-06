#include "methyl_on_111_cmssu.h"
#include "../../reactions/typical/migration_down_in_gap_from_111.h"

const ushort MethylOn111CMssu::__indexes[1] = { 0 };
const ushort MethylOn111CMssu::__roles[1] = { 27 };

#ifdef PRINT
const char *MethylOn111CMssu::name() const
{
    static const char value[] = "methyl_on_111(cm: **, cm: u)";
    return value;
}
#endif // PRINT

void MethylOn111CMssu::find(MethylOn111CMsu *parent)
{
    Atom *anchor = parent->atom(0);
    if (anchor->is(27))
    {
        if (!anchor->hasRole(METHYL_ON_111_CMssu, 27))
        {
            create<MethylOn111CMssu>(parent);
        }
    }
}

void MethylOn111CMssu::findAllTypicalReactions()
{
    MigrationDownInGapFrom111::find(this);
}
