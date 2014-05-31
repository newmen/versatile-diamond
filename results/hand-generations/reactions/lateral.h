#ifndef LATERAL_H
#define LATERAL_H

#include "registrator.h"

template <ushort RT, ushort LATERALS_NUM>
class Lateral : public Registrator<ConcreteLateralReaction<LATERALS_NUM>, RT>
{
    typedef Registrator<ConcreteLateralReaction<LATERALS_NUM>, RT> ParentType;

public:
    void remove() override;
    void unconcretizeBy(LateralSpec *spec) override;

protected:
    template <class... Args> Lateral(Args... args) : ParentType(args...) {}

    virtual void createUnconcreted(LateralSpec *spec) = 0;

    template <class R> void restoreParent();
};

//////////////////////////////////////////////////////////////////////////////////////

template <ushort RT, ushort LATERALS_NUM>
void Lateral<RT, LATERALS_NUM>::remove()
{
    ParentType::remove();
    Handbook::scavenger().markReaction(this->parent());
}

template <ushort RT, ushort LATERALS_NUM>
void Lateral<RT, LATERALS_NUM>::unconcretizeBy(LateralSpec *spec)
{
    ParentType::remove();
    createUnconcreted(spec);
}

template <ushort RT, ushort LATERALS_NUM>
template <class R>
void Lateral<RT, LATERALS_NUM>::restoreParent()
{
    // except LaterableRole::store()
    typedef typename R::RegistratorType RegistratorType;
    static_cast<R *>(this->parent())->RegistratorType::store();
}

#endif // LATERAL_H
