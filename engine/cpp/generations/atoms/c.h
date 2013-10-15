#ifndef C_H
#define C_H

#include "../../atom.h"
using namespace vd;

#define VALENCE 4

class C : public ConcreteAtom<VALENCE>
{
public:
    using ConcreteAtom::ConcreteAtom;

    bool is(uint typeOf) const override;
    bool prevIs(uint typeOf) const override;

    void specifyType() override;
    void findChildren() override;
};

#endif // C_H
