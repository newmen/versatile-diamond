#ifndef FINDER_H
#define FINDER_H

#include "../atoms/atom.h"

namespace vd
{

class Finder
{
public:
    static void initFind(Atom **atoms, int n);
    static void findAll(Atom **atoms, int n);
    static void removeAll(Atom **atoms, int n);

private:
    static void finalize();
};

}

#endif // FINDER_H
