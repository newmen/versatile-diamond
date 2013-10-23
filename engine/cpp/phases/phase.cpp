#include "phase.h"
#include "../atoms/atom.h"

namespace vd
{

void Phase::remove(Atom *atom)
{
    erase(atom);
    delete atom;
}

}
