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
    bool _visited = false;

protected:
    static BaseSpec *checkAndFind(Atom *anchor, ushort rType, ushort sType);

public:
    virtual ~BaseSpec() {}

    void setUnvisited() { _visited = false; }
    bool isVisited() { return _visited; }

    virtual ushort type() const = 0;

    virtual ushort size() const = 0;
    virtual Atom *atom(ushort index) const = 0;

    virtual Atom *firstLatticedAtomIfExist() = 0;

    virtual void findChildren();
    virtual void findAllChildren() = 0;

    void addChild(BaseSpec *child);
    void removeChild(BaseSpec *child);

    virtual void store() = 0;
    virtual void remove();

#ifdef PRINT
    virtual void eachAtom(const std::function<void (Atom *)> &lambda) = 0;

    virtual std::string name() const = 0;
    virtual void info() = 0;

    void wasFound();
    void wasForgotten();
#endif // PRINT

    Atom *anchor() const { return atom(indexes()[0]); }

protected:
    virtual ushort *indexes() const = 0;
    virtual ushort *roles() const = 0;
};

}

#endif // BASE_SPEC_H
