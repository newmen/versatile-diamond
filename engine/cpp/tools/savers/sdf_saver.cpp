#include "sdf_saver.h"

namespace vd
{

const char *SdfSaver::ext() const
{
    static const char value[] = ".sdf";
    return value;
}

const char *SdfSaver::separator() const
{
    static const char value[] = "$$$$\n";
    return value;
}

}
