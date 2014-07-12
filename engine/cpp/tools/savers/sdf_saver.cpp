#include "sdf_saver.h"

namespace vd
{

const char *SdfSaver::ext() const
{
    static const char value[] = ".sdf";
    return value;
}

std::string SdfSaver::separator() const
{
    return "$$$$\n";
}

}
