#ifndef FINDER_H
#define FINDER_H

#include "../atoms/atom.h"

namespace vd
{

class Finder
{
public:
    // This method must be defined by generations!
    static void findAll(Atom **atoms, int n, bool checkNull = false);
};

}

#endif // FINDER_H
