#ifndef LATTICE_H
#define LATTICE_H

#include "../tools/common.h"

namespace vd
{

template <class C>
class Lattice
{
    C *_crystal;
    int3 _coords;

public:
    Lattice(C *crystal, const int3 &coords) : _crystal(crystal), _coords(coords) {}

    C *crystal() { return _crystal; }

    const int3 &coords() const { return _coords; }
    void updateCoords(const int3 &coords) { _coords = coords; }

private:
    Lattice(const Lattice &) = delete;
    Lattice(Lattice &&) = delete;
    Lattice &operator = (const Lattice &) = delete;
    Lattice &operator = (Lattice &&) = delete;
};

}

#endif // LATTICE_H
