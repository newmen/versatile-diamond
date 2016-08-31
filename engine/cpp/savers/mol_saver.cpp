#include "mol_saver.h"

namespace vd
{

const char *MolSaver::ext() const
{
    static const char value[] = ".mol";
    return value;
}

}
