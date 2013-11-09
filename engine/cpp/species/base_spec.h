#ifndef BASE_SPEC_H
#define BASE_SPEC_H

#include <vector>
#include <unordered_set>
#include <memory>
#include "../atoms/atom.h"

#ifdef PRINT
#include <functional>
#include <string>
#endif // PRINT

namespace vd
{

class BaseSpec
{
    ushort _type;

public:
    BaseSpec(ushort type) : _type(type) {}
    virtual ~BaseSpec() {}

    ushort type() const { return _type; }

    virtual ushort size() const = 0;
    virtual Atom *atom(ushort index) = 0;
    virtual void eachAtom(const std::function<void (Atom *)> &lambda) = 0;

    virtual void findChildren() = 0;

#ifdef PRINT
    virtual std::string name() const = 0;
    virtual void info() = 0;

    void wasFound();
    void wasForgotten();
#endif // PRINT
};

}

#endif // BASE_SPEC_H
