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
    BondInfo(const BondInfo &) = default;

    bool operator == (const BondInfo &other) const;

    void incArity();

    uint type() const;
    uint from() const;
    uint to() const;

private:
    BondInfo(BondInfo &&) = delete;
    BondInfo &operator = (const BondInfo &) = delete;
    BondInfo &operator = (BondInfo &&) = delete;
};

}

//////////////////////////////////////////////////////////////////////////////////////

namespace std
{

using namespace vd;

template <>
struct hash<BondInfo>
{
    std::size_t operator () (const BondInfo &bi) const
    {
        return (bi._from << 16) ^ bi._to;
    }
};

}

#endif // BOND_INFO_H
