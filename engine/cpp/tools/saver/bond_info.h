#ifndef BOND_INFO_H
#define BOND_INFO_H

#include <string>
#include "../../tools/common.h"

namespace vd
{

class BondInfo
{
    uint _from, _to;
    uint _arity = 1;

    friend class std::hash<BondInfo>;

public:
    BondInfo(uint from, uint to) : _from(from), _to(to) {}

    bool operator == (const BondInfo &other) const;

    void incArity();

    uint type() const;
    uint from() const;
    uint to() const;
    std::string options() const;
};

}

namespace std
{

using namespace vd;

template <>
struct hash<BondInfo>
{
    std::size_t operator () (const BondInfo &bi) const
    {
        uint big, small;
        if (bi._from > bi._to)
        {
            big = bi._from;
            small = bi._to;
        }
        else
        {
            small = bi._from;
            big = bi._to;
        }

        return (small << 16) ^ big;
    }
};

}

#endif // BOND_INFO_H
