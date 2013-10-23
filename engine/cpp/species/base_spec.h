#ifndef BASE_SPEC_H
#define BASE_SPEC_H

#include <vector>
#include <unordered_set>
#include <memory>
#include "../atoms/atom.h"

namespace vd
{

class BaseSpec
{
    ushort _type;

public:
    BaseSpec(ushort type) : _type(type) {}
    virtual ~BaseSpec() {}

    ushort type() const { return _type; }

    virtual Atom *atom(ushort index) = 0;
    virtual ushort size() const = 0;

    virtual void findChildren() = 0;
};

}

#endif // BASE_SPEC_H
