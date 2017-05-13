#ifndef BEHAVIOR_TOR_H
#define BEHAVIOR_TOR_H

#include "behavior.h"

namespace vd
{

class BehaviorTor : public Behavior
{
public:
    BehaviorTor() = default;

    Atom *&choiseAtom(SmartAtomsVector3d<Atom> *atomsVector, const int3 &coords) const override;

private:
    int3 correct(const SmartAtomsVector3d<Atom> *atomsVector, const int3 &coords) const;
    int correctOne(int value, uint max) const;
};

}

#endif // BEHAVIOR_TOR_H
