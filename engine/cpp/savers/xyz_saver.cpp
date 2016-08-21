#include "xyz_saver.h"

namespace vd
{

const char *XYZSaver::ext() const
{
    static const char value[] = ".xyz";
    return value;
}

}
