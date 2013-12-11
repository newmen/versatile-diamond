#ifndef CONCRETE_LATERAL_SPEC_H
#define CONCRETE_LATERAL_SPEC_H

#include "lateral_spec.h"

#ifdef PRINT
#include <sstream>
#endif // PRINT

namespace vd
{

template <class S>
class ConcreteLateralSpec : public LateralSpec
{
    S *_parent = nullptr;

public:
    enum : ushort { ID = S::ID };
    enum : ushort { UsedAtomsNum = S::UsedAtomsNum };

    ushort type() const override { return _parent->type(); }

    void setUnvisited() override { _parent->setUnvisited(); }
    void setVisited() override { _parent->setVisited(); }
    bool isVisited() const override { return _parent->isVisited(); }

    ushort size() const override { return _parent->size(); }
    Atom *atom(ushort index) const override { return _parent->atom(index); }

    Atom *anchor() override { return _parent->anchor(); }

    void addChild(BaseSpec *child) override { _parent->addChild(child); }
    void removeChild(BaseSpec *child) override { _parent->removeChild(child); }

    void store() override;
    void remove() override;

#ifdef PRINT
    void eachAtom(const std::function<void (Atom *)> &lambda) override { _parent->eachAtom(lambda); }
    void info(std::ostream &os) override { _parent->info(os); }
    std::string name() const override;
#endif // PRINT

    ushort *indexes() const override { return _parent->indexes(); }
    ushort *roles() const override { return _parent->roles(); }

protected:
    template <class... Args>
    ConcreteLateralSpec(Args... args) : _parent(new S(args...)) {}
    ~ConcreteLateralSpec() { delete _parent; }

    void findAllChildren() override { assert(false); }
};

template <class S>
void ConcreteLateralSpec<S>::store()
{
    _parent->eachParent([this](BaseSpec *parent) {
        parent->addChild(this);
    });
}

template <class S>
void ConcreteLateralSpec<S>::remove()
{
    _parent->eachParent([this](BaseSpec *parent) {
        parent->removeChild(this);
    });

    _parent->ParentSpec::remove(); // removes all children of current spec
}

#ifdef PRINT
template <class S>
std::string ConcreteLateralSpec<S>::name() const
{
    std::stringstream ss;
    ss << "lateral " << _parent->name();
    return ss.str();
}
#endif // PRINT

}

#endif // CONCRETE_LATERAL_SPEC_H
