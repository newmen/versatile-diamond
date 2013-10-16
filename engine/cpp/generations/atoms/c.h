#ifndef C_H
#define C_H

#include "specified_atom.h"

#define VALENCE 4

class C : public SpecifiedAtom<VALENCE>
{
public:
    using SpecifiedAtom::SpecifiedAtom;

    void findChildren() override;
};

#endif // C_H
