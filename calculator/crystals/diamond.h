#ifndef DIAMOND_H
#define DIAMOND_H

#include "../crystal.h"
using namespace vd;

class Diamond : public Crystal
{
public:
    using Crystal::Crystal;

    void bondTogether();
};

#endif // DIAMOND_H
