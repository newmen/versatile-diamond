#include "xyz_saver.h"
#include "xyz_accumulator.h"
#include "xyz_format.h"

namespace vd
{

const char *XYZSaver::ext() const
{
    static const char value[] = ".xyz";
    return value;
}

}
