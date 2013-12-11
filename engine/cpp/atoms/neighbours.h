#ifndef NEIGHBOURS_H
#define NEIGHBOURS_H

#include "../tools/common.h"
#include "atom.h"

namespace vd
{

template <ushort NUM>
class Neighbours
{
    Atom *_atoms[NUM];

public:
    enum : ushort { QUANTITY = NUM };

    Neighbours()
    {
        for (int i = 0; i < NUM; ++i)
        {
            _atoms[i] = nullptr;
        }
    }

    Neighbours(Atom *atoms[NUM])
    {
        for (int i = 0; i < NUM; ++i)
        {
            _atoms[i] = atoms[i];
        }
    }

    Atom *operator[](uint i)
    {
        return _atoms[i];
    }

    bool all()
    {
        bool result = true;
        for (int i = 0; i < NUM; ++i)
        {
            result = result && (_atoms[i] != nullptr);
        }
        return result;
    }
};

}

#endif // NEIGHBOURS_H
