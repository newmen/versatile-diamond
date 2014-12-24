#ifndef BRIDGE_H
#define BRIDGE_H

#include "../../phases/diamond_atoms_iterator.h"
#include "../empty/symmetric_bridge.h"
#include "original_bridge.h"

class Bridge : public Symmetric<OriginalBridge, SymmetricBridge>, public DiamondAtomsIterator
{
public:
    static void find(Atom *anchor);

    Bridge(Atom **atoms) : Symmetric(atoms) {}

protected:
    void findAllChildren() final;
};

#endif // BRIDGE_H
