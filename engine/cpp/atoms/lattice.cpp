#include "lattice.h"

namespace vd
{

Lattice::Lattice(Crystal *crystal, int3 &&coords) : _crystal(crystal), _coords(std::move(coords))
{
}

}
