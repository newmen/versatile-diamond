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
    std::unordered_set<BaseSpec *> _children;

public:
    virtual ~BaseSpec() {}

    virtual ushort type() const = 0;

    virtual ushort size() const = 0;
    virtual Atom *atom(ushort index) = 0;
    // TODO: maybe need to change it to method without lambda, which will returns only first latticed atom
    virtual void eachAtom(const std::function<void (Atom *)> &lambda) = 0;

    virtual void findChildren() = 0;
    void addChild(BaseSpec *child);
    void removeChild(BaseSpec *child);

    virtual void store() = 0;
    virtual void remove();

#ifdef PRINT
    virtual std::string name() const = 0;
    virtual void info() = 0;

    void wasFound();
    void wasForgotten();
#endif // PRINT
};

}

#endif // BASE_SPEC_H
