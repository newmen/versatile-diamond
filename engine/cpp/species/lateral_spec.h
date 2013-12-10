#ifndef LATERAL_SPEC_H
#define LATERAL_SPEC_H

#include "../reactions/lateral_reaction.h"
#include "base_spec.h"
#include "parent_spec.h"
#include "reactant.h"

namespace vd
{

class LateralSpec : public Reactant<BaseSpec, LateralReaction>
{
    ParentSpec *_parent;

public:
    void setUnvisited() override { _parent->setUnvisited(); }
    bool isVisited() const override { return _parent->isVisited(); }

    ushort type() const override { return _parent->type(); }

    ushort size() const override { return _parent->size(); }
    Atom *atom(ushort index) const override { return _parent->atom(index); }

    Atom *anchor() override { return _parent->anchor(); }

    void addChild(BaseSpec *child) override { _parent->addChild(child); }
    void removeChild(BaseSpec *child) override { _parent->removeChild(child); }

#ifdef PRINT
    void eachAtom(const std::function<void (Atom *)> &lambda) override { _parent->eachAtom(lambda); }
    void info(std::ostream &os) override { _parent->info(os); }
    std::string name() const override;
#endif // PRINT

protected:
    LateralSpec(ParentSpec *parent) : _parent(parent) {}
    ~LateralSpec() { delete _parent; }

    void setVisited() override { _parent->setVisited(); }
    void findAllChildren() override { _parent->findAllChildren(); }

    ushort *indexes() const override { return _parent->indexes(); }
    ushort *roles() const override { return _parent->roles(); }
};

}

#endif // LATERAL_SPEC_H
