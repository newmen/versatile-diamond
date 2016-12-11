#include "methyl_on_111_cmssiu.h"
#include "../../reactions/typical/migration_down_in_gap_from_111.h"

template <> const ushort MethylOn111CMssiu::Base::__indexes[1] = { 0 };
template <> const ushort MethylOn111CMssiu::Base::__roles[1] = { 27 };

#if defined(PRINT) || defined(SERIALIZE)
const char *MethylOn111CMssiu::name() const
{
    static const char value[] = "methyl_on_111(cm: **, cm: i, cm: u)";
    return value;
}
#endif // PRINT || SERIALIZE

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
