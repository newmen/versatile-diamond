#include "lattice.h"

namespace vd
{

Lattice::Lattice(const Crystal *crystal, const int3 &coords) : _crystal(crystal), _coords(coords)
{
}

}
