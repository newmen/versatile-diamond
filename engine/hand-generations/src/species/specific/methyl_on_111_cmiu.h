#ifndef METHYL_ON_111_CMIU_H
#define METHYL_ON_111_CMIU_H

#include "../base/methyl_on_bridge.h"
#include "../specific.h"

class MethylOn111CMiu : public Specific<Base<DependentSpec<ParentSpec>, METHYL_ON_111_CMiu, 2>>
{
public:
    static void find(MethylOnBridge *parent);

    MethylOn111CMiu(ParentSpec *parent) : Specific(parent) {}

#ifdef PRINT
    const char *name() const final;
#endif // PRINT

protected:
    void findAllChildren() final;
    void findAllTypicalReactions() final;
};

#endif // METHYL_ON_111_CMIU_H
