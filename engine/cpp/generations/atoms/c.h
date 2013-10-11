#ifndef C_H
#define C_H

#include "../../atom.h"
using namespace vd;

#define VALENCE 4

class C : public ConcreteAtom<VALENCE>
{
public:
    using ConcreteAtom::ConcreteAtom;

    void findSpecs() override;
};

#endif // C_H
