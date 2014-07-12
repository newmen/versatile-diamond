#ifndef VOLUME_ATOM_H
#define VOLUME_ATOM_H

#include "../../atoms/atom.h"

namespace vd
{

class VolumeAtom
{
    const Atom *_atom;

public:
    VolumeAtom(const Atom *atom) : _atom(atom) {}

    float3 coords() const;
    const Atom *atom() const { return _atom; }
};

}

#endif // VOLUME_ATOM_H
