#ifndef BASE_SPEC_H
#define BASE_SPEC_H

#include "../atoms/atom.h"
#include "../tools/creator.h"

#ifdef PRINT
#include <functional>
#include <iostream>
#include <string>
#endif // PRINT

namespace vd
{

class BaseSpec : public Creator
{
public:
    virtual ~BaseSpec() {}

    virtual void setUnvisited() = 0;
    virtual bool isVisited() const = 0;

    virtual ushort type() const = 0;

    virtual ushort size() const = 0;
    virtual Atom *atom(ushort index) const = 0;

    virtual Atom *anchor() = 0;

    virtual void findChildren();
    virtual void addChild(BaseSpec *child) = 0;
    virtual void removeChild(BaseSpec *child) = 0;

    virtual void store() = 0;
    virtual void remove() = 0;

#ifdef PRINT
    virtual void eachAtom(const std::function<void (Atom *)> &lambda) = 0;

    virtual std::string name() const = 0;
    virtual void info(std::ostream &os) = 0;

    void wasFound();
    void wasForgotten();
#endif // PRINT

protected:
    virtual void setVisited() = 0;
    virtual void findAllChildren() = 0;

    virtual ushort *indexes() const = 0;
    virtual ushort *roles() const = 0;
};

}

#endif // BASE_SPEC_H
