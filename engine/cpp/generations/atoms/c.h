#ifndef C_H
#define C_H

#include "../../atom.h"
using namespace vd;

#define VALENCE 4

class C : public ConcreteAtom<VALENCE>
{
    static Atom *__accordance = {

    };

public:
    using ConcreteAtom::ConcreteAtom;

    bool is(uint type) override;

    void specifyType() override;
    void findSpecs() override;
};

#endif // C_H
