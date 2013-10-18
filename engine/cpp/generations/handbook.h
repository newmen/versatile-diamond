#ifndef HANDBOOK_H
#define HANDBOOK_H

#include <omp.h>
#include "../common.h"

#include "dmc.h"
#include "names.h"
#include "crystals/diamond.h"
#include "base_specs/bridge.h"
#include "base_specs/dimer.h"
#include "specific_specs/bridge_cts.h"

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

class Handbook
{
    static DMC __mc;
public:
    static DMC &mc();

    // atoms
private:
    static const ushort __atomsNum;
    static const bool __atomsAccordance[];

    static const ushort __atomsSpecifing[];

public:
    static bool atomIs(ushort complexType, ushort typeOf);
    static ushort specificate(ushort type);

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

    static std::unordered_set<BridgeCts *> __bridgeCtss;

public:
    static void storeBridge(Bridge *bridge) { store(&__bridges, bridge); }
    static void removeBridge(Bridge *bridge) { remove(&__bridges, bridge); }

    static void storeDimer(Dimer *dimer) { store(&__dimers, dimer); }
    static void removeDimer(Dimer *dimer) { remove(&__dimers, dimer); }

    static void storeBridgeCts(BridgeCts *bridgeCts) { store(&__bridgeCtss, bridgeCts); }
    static void removeBridgeCts(BridgeCts *bridgeCts) { remove(&__bridgeCtss, bridgeCts); }
};

#endif // HANDBOOK_H
