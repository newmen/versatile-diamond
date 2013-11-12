#ifndef FINDER_H
#define FINDER_H

#include "../atoms/atom.h"

namespace vd
{

class Finder
{
public:
    static void findAll(Atom **atoms, int n, bool isInit = false);
    static void removeAll(Atom **atoms, int n);
};

}

#endif // FINDER_H
