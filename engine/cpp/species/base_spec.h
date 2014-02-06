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
    virtual Atom *anchor() const = 0;

    virtual void setUnvisited() {}
    virtual void findChildren() {}

    virtual void store();
    virtual void remove();

#ifdef PRINT
    virtual void eachAtom(const std::function<void (Atom *)> &lambda) = 0;

    virtual std::string name() const = 0;
    virtual void info(std::ostream &os) = 0;

private:
    void wasFound();
    void wasForgotten();
#endif // PRINT

protected:
    BaseSpec() = default;
};

}

#endif // BASE_SPEC_H
