#ifndef NEIGHBOURS_H
#define NEIGHBOURS_H

#include "atom.h"

namespace vd
{

template <int NUM>
struct Neighbours
{
    Atom *atoms[NUM];

    Neighbours(Atom *atoms[NUM])
    {
        for (int i = 0; i < NUM; ++i)
        {
            this->atoms[i] = atoms[i];
        }
    }
};

}

#endif // NEIGHBOURS_H
