#ifndef DICTIONARY_H
#define DICTIONARY_H

#include <omp.h>
#include "../common.h"

#include "dmc.h"
#include "base_specs/bridge.h"
#include "base_specs/dimer.h"

#include <iostream>
using namespace std;

template <class S>
void store(std::unordered_set<S *> *container, S *item)
{
#pragma omp critical
    container->insert(item);
}

template <class S>
void remove(std::unordered_set<S *> *container, S *item)
{
#pragma omp critical
    {
        container->erase(item);
        delete item;
    }
}

template <class S>
void purge(std::unordered_set<S *> *container)
{
//    cout << (*container.begin())->size() << " -> " << container.size() << endl;

    for (S *item : *container)
    {
//        cout << item->size() << " -> " << item->anchor()->lattice()->coords() << endl;
        delete item;
    }
}

class Dictionary
{
    static DMC __mc;
public:
    static DMC &mc();

    // atoms
private:
    static const uint __atomsNum;
    static const bool __atomsAccordance[];

public:
    static bool atomIs(uint complexType, uint typeOf);

    // ubiquitous reactions
private:
    static const ushort __activesOnAtoms[];
    static const ushort __hOnAtoms[];

    static const short __activesToH[];
    static const short __hToActives[];

public:
    static ushort activesNum(uint type);
    static ushort hNum(uint type);

    static short activesToH(uint type);
    static short hToActives(uint type);

    // specs
//private:
//    static std::vector<BaseSpec *> __newSpecs;

//    static void addNew(BaseSpec *spec);

public:
//    static void clearNews();
    static void purge();

    static uint specsNum();

private:
    static std::unordered_set<Bridge *> __bridges;
    static std::unordered_set<Dimer *> __dimers;

public:
    static void storeBridge(Bridge *bridge) { store(&__bridges, bridge); }
    static void removeBridge(Bridge *bridge) { remove(&__bridges, bridge); }

    static void storeDimer(Dimer *dimer) { store(&__dimers, dimer); }
    static void removeDimer(Dimer *dimer) { remove(&__dimers, dimer); }
};

#endif // DICTIONARY_H
