#ifndef DEACTIVATION_DATA_H
#define DEACTIVATION_DATA_H

#include "../../ubiquitous.h"

template <ushort RT>
class DeactivationData : public Ubiquitous<RT>
{
    typedef Ubiquitous<RT> ParentType;

public:
    static const ushort *nums();

protected:
    DeactivationData(Atom *target) : ParentType(target) {}

    ushort toType() const override;
    void action() override;
};

//////////////////////////////////////////////////////////////////////////////////////

template <ushort RT>
const ushort *DeactivationData<RT>::nums()
{
    return Handbook::__activesOnAtoms;
}

template <ushort RT>
ushort DeactivationData<RT>::toType() const
{
    return Handbook::activesToHFor(this->target()->type());
}

template <ushort RT>
void DeactivationData<RT>::action()
{
     this->target()->deactivate();
}

#endif // DEACTIVATION_DATA_H
