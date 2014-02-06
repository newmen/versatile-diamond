#include "methyl_on_111_cmsu.h"
#include "../../reactions/typical/migration_down_at_dimer_from_111.h"
#include "methyl_on_111_cmssu.h"

const ushort MethylOn111CMsu::__indexes[1] = { 0 };
const ushort MethylOn111CMsu::__roles[1] = { 26 };

#ifdef PRINT
const char *MethylOn111CMsu::name() const
{
    static const char value[] = "methyl_on_111(cm: *, cm: u)";
    return value;
}
#endif // PRINT

void MethylOn111CMsu::find(MethylOn111CMu *parent)
{
    Atom *anchor = parent->atom(0);
    if (anchor->is(26))
    {
        if (!anchor->hasRole(METHYL_ON_111_CMsu, 26))
        {
            create<MethylOn111CMsu>(parent);
        }
    }
}

void MethylOn111CMsu::findAllChildren()
{
    MethylOn111CMssu::find(this);
}

void MethylOn111CMsu::findAllTypicalReactions()
{
    MigrationDownAtDimerFrom111::find(this);
}
