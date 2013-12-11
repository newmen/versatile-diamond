#ifndef PHASE_BOUNDARY_H
#define PHASE_BOUNDARY_H

#include "../../phases/amorph.h"
using namespace vd;

class PhaseBoundary : public Amorph
{
public:
    ~PhaseBoundary();

    void clear();
};

#endif // PHASE_BOUNDARY_H
