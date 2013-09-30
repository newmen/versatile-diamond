#include "lattice.h"

namespace vd
{

Lattice::Lattice(const Crystal *crystal, const uint3 &coords) : _crystal(crystal), _coords(coords)
{
}

}
