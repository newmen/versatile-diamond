#ifndef LATTICE_H
#define LATTICE_H

#include "../tools/common.h"
#include "../phases/crystal.h"

namespace vd
{

class Lattice
{
    Crystal *_crystal;
    int3 _coords;

public:
    Lattice(Crystal *crystal, int3 &&coords);

    Crystal *crystal() { return _crystal; }
    const Crystal *crystal() const { return _crystal; }
    const int3 &coords() const { return _coords; }
    void updateCoords(int3 &&coords) { _coords = std::move(coords); }

private:
    Lattice(const Lattice &) = delete;
    Lattice(Lattice &&) = delete;
    Lattice &operator = (const Lattice &) = delete;
    Lattice &operator = (Lattice &&) = delete;
};

}

#endif // LATTICE_H
