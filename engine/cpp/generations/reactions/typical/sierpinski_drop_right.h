#ifndef SIERPINSKI_DROP_RIGHT_H
#define SIERPINSKI_DROP_RIGHT_H

#include "sierpinski_drop.h"

class SierpinskiDropRight : public SierpinskiDrop
{
public:
    SierpinskiDropRight(SpecificSpec *target) : SierpinskiDrop(target) {}

    void doIt() override;
};

#endif // SIERPINSKI_DROP_RIGHT_H
