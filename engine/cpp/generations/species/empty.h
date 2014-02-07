#ifndef EMPTY_H
#define EMPTY_H

#include "../../species/empty_spec.h"
using namespace vd;

#include "overall.h"

template <template <class> class W, ushort ST>
class Empty : public Overall<W<DependentSpec<EmptySpec>>, ST>
{
    typedef Overall<W<DependentSpec<EmptySpec>>, ST> ParentType;

public:
    Atom *anchor() const override { return this->parent(0)->anchor(); }

    void remove() override;

protected:
    template <class... Args> Empty(Args... args) : ParentType(args...) {}

    void findAllChildren() override {}
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <template <class> class W, ushort ST>
void Empty<W, ST>::remove()
{
    if (this->isMarked()) return;

    ParentType::remove();
}

#endif // EMPTY_H
