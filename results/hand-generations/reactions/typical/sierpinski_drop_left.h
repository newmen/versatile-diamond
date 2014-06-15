#ifndef SIERPINSKI_DROP_LEFT_H
#define SIERPINSKI_DROP_LEFT_H

#include "sierpinski_drop.h"

class SierpinskiDropLeft : public SierpinskiDrop
{
public:
    SierpinskiDropLeft(SpecificSpec *target) : SierpinskiDrop(target) {}

    void doIt() override;
};

#endif // SIERPINSKI_DROP_LEFT_H
