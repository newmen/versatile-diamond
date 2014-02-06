#ifndef SEALER_H
#define SEALER_H

#include "../atoms/atom.h"

namespace vd
{

// Where the B class should be a BaseSpec class and the U class should be a Reactant class
template <class B, class U>
class Sealer : public B, public U
{
public:
    ushort type() const override { return B::type(); }

    Atom *atom(ushort index) const override { return B::atom(index); }
    Atom *anchor() const override { return B::anchor(); }

    void store() override;

protected:
    template <class... Args> Sealer(Args... args) : B(args...) {}
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class B, class U>
void Sealer<B, U>::store()
{
    B::store();
    U::keep();
}

}

#endif // SEALER_H
