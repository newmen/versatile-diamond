#include "bond_info.h"

namespace vd
{

bool BondInfo::operator == (const BondInfo &other) const
{
    return _from == other._from && _to == other._to;
}

void BondInfo::incArity()
{
    ++_arity;
}

uint BondInfo::type() const
{
    return _arity;
}

uint BondInfo::from() const
{
    return _from;
}

uint BondInfo::to() const
{
    return _to;
}

std::string BondInfo::options() const
{
    return "";
}

}
