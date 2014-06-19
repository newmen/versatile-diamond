#ifndef HANDBOOK_H
#define HANDBOOK_H

#include <mc/mc.h>
#include <tools/common.h>
#include <tools/scavenger.h>
#include <species/keeper.h>
#include <species/lateral_spec.h>
#include <species/specific_spec.h>
using namespace vd;

#include "env.h"
#include "finder.h"
#include "names.h"
#include "phases/diamond.h"
#include "phases/phase_boundary.h"

class Handbook
{
    typedef MC<ALL_SPEC_REACTIONS_NUM, UBIQUITOUS_REACTIONS_NUM> DMC;

    typedef Keeper<LateralSpec, &LateralSpec::findLateralReactions> LKeeper;
    typedef Keeper<SpecificSpec, &SpecificSpec::findTypicalReactions> SKeeper;

    static DMC __mc;
    static PhaseBoundary __amorph;

    static LKeeper __lateralKeepers[THREADS_NUM];
    static SKeeper __specificKeepers[THREADS_NUM];

    static Scavenger __scavengers[THREADS_NUM];

public:
    ~Handbook();

    static DMC &mc();

    static PhaseBoundary &amorph();

    static SKeeper &specificKeeper();
    static LKeeper &lateralKeeper();

    static Scavenger &scavenger();

private:
    template <class T> static inline T &selectForThread(T *container);

    static const ushort __atomsNum;

    static const bool __atomsAccordance[];
    static const ushort __atomsSpecifing[];

public:
    static const ushort __hToActives[];
    static const ushort __hOnAtoms[];
    static const ushort __activesOnAtoms[];
    static const ushort __activesToH[];

public:
    static bool atomIs(ushort complexType, ushort typeOf);
    static ushort specificate(ushort type);
};

//////////////////////////////////////////////////////////////////////////////////////

template <class T>
T &Handbook::selectForThread(T *container)
{
#ifdef PARALLEL
    return container[omp_get_thread_num()];
#else
    return container[0];
#endif // PARALLEL
}

#endif // HANDBOOK_H