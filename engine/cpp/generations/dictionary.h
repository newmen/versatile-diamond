#ifndef DICTIONARY_H
#define DICTIONARY_H

#include <omp.h>
#include "../common.h"

#include "dmc.h"
#include "base_specs/bridge.h"
#include "base_specs/dimer.h"

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
    for (S *item : *container) delete item;
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

    static const ushort __atomsSpecifing[];

public:
    static bool atomIs(uint complexType, uint typeOf);
    static ushort specificate(uint type);

    // ubiquitous reactions
private:
    static const ushort __activesOnAtoms[];
    static const ushort __hOnAtoms[];

    static const ushort __activesToH[];
    static const ushort __hToActives[];

public:
    static ushort activesNum(uint type);
    static ushort hNum(uint type);

    static ushort activesToH(uint type);
    static ushort hToActives(uint type);

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
