#include <sstream>
#include "dump_saver.h"
#include "../../atoms/atom.h"
#include "../mol_accumulator.h"

namespace vd {

const char *DumpSaver::ext() const
{
    static const char value[] = ".dump";
    return value;
}

}
