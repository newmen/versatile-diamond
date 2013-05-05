#include "atom.h"
#include <assert.h>

#include <cstring>

namespace vd
{

Atom::Atom(const char *name, uint valence, const Lattice *lattice) : _valence(valence), _lattice(lattice)
{
    strcpy(_name, name);
}

Atom::~Atom()
{
    if (_lattice != 0) escape();
}

void Atom::addNeighbour(Atom *neighbour)
{
    assert(activeBonds() > 0);
    _neighbours.insert(neighbour);
}

bool Atom::isNeighbour(Atom *neighbour) const
{
    return _neighbours.find(neighbour) != _neighbours.cend();
}

uint Atom::activeBonds() const
{
    return _valence - _neighbours.size();
}

void Atom::escape()
{
    assert(_lattice != 0);
    delete _lattice;
    _lattice = 0;
}

}
