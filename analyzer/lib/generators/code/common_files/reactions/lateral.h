#ifndef LATERAL_H
#define LATERAL_H

#include "registrator.h"

template <class B, ushort RT>
class Lateral : public Registrator<B, RT>
{
    typedef Registrator<B, RT> ParentType;

public:
    void remove() override;
    void unconcretizeBy(LateralSpec *spec) override;

protected:
    template <class... Args> Lateral(Args... args) : ParentType(args...) {}

    virtual void createUnconcreted(LateralSpec *spec);

private:
    void restoreParent();
};

//////////////////////////////////////////////////////////////////////////////////////

template <class B, ushort RT>
void Lateral<B, RT>::remove()
{
    ParentType::remove();
    Handbook::scavenger().markReaction(this->parent());
}

template <class B, ushort RT>
void Lateral<B, RT>::unconcretizeBy(LateralSpec *spec)
{
    ParentType::remove();
    createUnconcreted(spec);
}

template <class B, ushort RT>
void Lateral<B, RT>::createUnconcreted(LateralSpec *)
{
    restoreParent();
}

template <class B, ushort RT>
void Lateral<B, RT>::restoreParent()
{
    this->parent()->TypicalReaction::store();
}

#endif // LATERAL_H
