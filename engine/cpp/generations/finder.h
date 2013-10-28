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

private:
    static void findByOne(Atom *atom, bool checkNull);
    static void findByMany(Atom **atoms, int n, bool checkNull);
};

}

#endif // FINDER_H
