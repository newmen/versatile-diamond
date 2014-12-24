#include "mol_saver.h"
#include "mol_accumulator.h"
#include "mol_format.h"

namespace vd
{

const char *MolSaver::ext() const
{
    static const char value[] = ".mol";
    return value;
}

}
