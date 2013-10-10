#ifndef DIAMOND_H
#define DIAMOND_H

#include "../../crystal.h"
using namespace vd;

class Diamond : public Crystal
{
public:
    using Crystal::Crystal;

protected:
    void buildAtoms();
    void bondAllAtoms();

};

#endif // DIAMOND_H
