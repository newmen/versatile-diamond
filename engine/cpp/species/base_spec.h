#ifndef BASE_SPEC_H
#define BASE_SPEC_H

#include <functional>
#include "../tools/common.h"
#include "../tools/creator.h"

namespace vd
{

class Atom;

class BaseSpec : public Creator
{
public:
    virtual ~BaseSpec() {}

    virtual ushort type() const = 0;

    virtual ushort size() const = 0;
    virtual Atom *atom(ushort index) const = 0;

    virtual void setUnvisited() {}
    virtual void findChildren() {}

    virtual void store();
    virtual void remove();

#if defined(PRINT) || defined(SERIALIZE)
    virtual const char *name() const = 0;
#endif // PRINT || SERIALIZE
#ifdef PRINT
    virtual void info(IndentStream &os) = 0;
    virtual void eachAtom(const std::function<void (Atom *)> &lambda) = 0;

private:
    void wasFound();
    void wasForgotten();
#endif // PRINT

protected:
    BaseSpec() = default;

private:
    BaseSpec(const BaseSpec &) = delete;
    BaseSpec(BaseSpec &&) = delete;
    BaseSpec &operator = (const BaseSpec &) = delete;
    BaseSpec &operator = (BaseSpec &&) = delete;
};

}

#endif // BASE_SPEC_H
