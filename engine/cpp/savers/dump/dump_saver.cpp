#include "dump_saver.h"

namespace vd
{

const char *DumpSaver::ext() const
{
    static const char value[] = ".dump";
    return value;
}

}
