#include "common.h"

namespace vd
{

std::ostream &operator << (std::ostream &os, const int3 &v)
{
    os << "(" << v.x << ", " << v.y << ", " << v.z << ")";
    return os;
}

}
