#ifndef ATOM_H
#define ATOM_H

#include <unordered_set>
#include "lattice.h"

namespace vd
{

class Atom
{
    char _name[3];
    const uint _valence;
    std::unordered_multiset<Atom *> _neighbours;
    const Lattice *_lattice;

public:
    Atom(const char *name, uint valence, const Lattice *lattice = 0);
    ~Atom();

    void addNeighbour(Atom *neighbour);
    bool isNeighbour(Atom *neighbour) const;

    uint activeBonds() const;

private:
    void escape();
};

}

#endif // ATOM_H
