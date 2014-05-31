#ifndef ACTIVATION_DATA_H
#define ACTIVATION_DATA_H

#include "../../ubiquitous.h"

template <ushort RT>
class ActivationData : public Ubiquitous<RT>
{
    typedef Ubiquitous<RT> ParentType;

public:
    static const ushort *nums();

protected:
    ActivationData(Atom *target) : ParentType(target) {}

    ushort toType() const override;
    void action() override;
};

//////////////////////////////////////////////////////////////////////////////////////

template <ushort RT>
const ushort *ActivationData<RT>::nums()
{
    return Handbook::__hOnAtoms;
}

template <ushort RT>
ushort ActivationData<RT>::toType() const
{
    return Handbook::__hToActives[this->target()->type()];
}

template <ushort RT>
void ActivationData<RT>::action()
{
     this->target()->activate();
}

#endif // ACTIVATION_DATA_H
