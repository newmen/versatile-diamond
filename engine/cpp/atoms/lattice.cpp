#include "lattice.h"

namespace vd
{

Lattice::Lattice(Crystal *crystal, const int3 &coords) : _crystal(crystal), _coords(coords)
{
}

}
