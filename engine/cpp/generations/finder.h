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

private:
    // This methods must be defined by generations!
    static void findByOne(Atom *atom, bool checkNull);
    static void findByMany(Atom **atoms, int n, bool isInit);

    static void finalize();
};

}

#endif // FINDER_H
