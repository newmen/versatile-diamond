#include "atom_info.h"
#include <sstream>

namespace vd
{

bool AtomInfo::operator == (const AtomInfo &other) const
{
    return atom() == other.atom();
}

void AtomInfo::incNoBond()
{
    ++_noBond;
}

const char *AtomInfo::type() const
{
    return atom()->name();
}

}
