#include "specified_atom.h"
#include "../handbook.h"

bool SpecifiedAtom::is(ushort typeOf) const
{
    return Atom::type() != NO_VALUE && Handbook::atomIs(Atom::type(), typeOf);
}

bool SpecifiedAtom::prevIs(ushort typeOf) const
{
    return Atom::prevType() != NO_VALUE && Handbook::atomIs(Atom::prevType(), typeOf);
}

void SpecifiedAtom::specifyType()
{
    Atom::setType(Handbook::specificate(Atom::type()));
}
