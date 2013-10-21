#include "phase.h"
#include "atom.h"

namespace vd
{

void Phase::remove(Atom *atom)
{
    erase(atom);
    delete atom;
}

}
