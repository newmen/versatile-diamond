#ifndef NEIGHBOURS_H
#define NEIGHBOURS_H

#include "atom.h"

namespace vd
{

template <int NUM>
class Neighbours
{
    Atom *atoms[NUM];

public:
    Neighbours(Atom *atoms[NUM])
    {
        for (int i = 0; i < NUM; ++i)
            this->atoms[i] = atoms[i];
    }

    Atom *operator [] (uint i)
    {
        return atoms[i];
    }

    bool all()
    {
        return atoms[0] && atoms[1];
    }
};

}

#endif // NEIGHBOURS_H
