#ifndef METHYL_ON_DIMER_H
#define METHYL_ON_DIMER_H

#include "bridge.h"
#include "methyl_on_bridge.h"

class MethylOnDimer :
        public Base<DependentSpec<ParentSpec, 2>, METHYL_ON_DIMER, 2>,
        public DiamondAtomsIterator
{
public:
    static void find(Atom *anchor);

    MethylOnDimer(ParentSpec **parents) : Base(parents) {}

#if defined(PRINT) || defined(SERIALIZE)
    const char *name() const override;
#endif // PRINT || SERIALIZE

protected:
    void findAllChildren() final;
};

#endif // METHYL_ON_DIMER_H
