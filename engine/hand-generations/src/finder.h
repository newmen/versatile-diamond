#ifndef FINDER_H
#define FINDER_H

#include <atoms/atom.h>
using namespace vd;

class Finder
{
public:
    static void initFind(Atom **atoms, uint n);
    static void findAll(Atom **atoms, uint n);
    static void removeAll(Atom **atoms, uint n);

private:
    static void finalize();
};

#endif // FINDER_H
