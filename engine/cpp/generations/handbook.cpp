#include "handbook.h"

#ifdef PARALLEL
#include <omp.h>
#endif // PARALLEL

// 32 :: -^C%d<
// 33 :: ~^C%d<
// 34 :: ^HC%d<
// 35 :: HC:i:u~
// 36 :: H*C:i:u~
const ushort Handbook::atomsNum = 37;
const bool Handbook::__atomsAccordance[37 * 37] = {
/*  0 */  true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/*  1 */  false, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/*  2 */  true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false,
/*  3 */  false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/*  4 */  false, false, false, true, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/*  5 */  false, true, false, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/*  6 */  false, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/*  7 */  false, false, false, true, false, false, false, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/*  8 */  false, true, false, true, false, false, false, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/*  9 */  false, false, false, true, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 10 */  false, false, false, false, false, false, false, false, false, false, true, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 11 */  false, false, false, false, false, false, false, false, false, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 12 */  false, false, false, false, false, false, false, false, false, false, false, true, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 13 */  false, false, false, false, false, false, false, false, false, false, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, true, true, true, false, true, true, true, false, false, false, false, false,
/* 14 */  false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 15 */  false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 16 */  false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 17 */  false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 18 */  false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 19 */  false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 20 */  false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 21 */  false, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 22 */  false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 23 */  false, false, false, true, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 24 */  false, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false,
/* 25 */  false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, true, false, false, false, false, false,
/* 26 */  false, false, false, false, false, false, false, false, false, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, true, true, false, false, true, false, true, false, false, false, false, false,
/* 27 */  false, false, false, false, false, false, false, false, false, false, false, true, true, false, true, false, false, false, false, false, false, false, false, false, false, true, true, true, false, true, true, true, false, false, false, true, true,
/* 28 */  true, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false,
/* 29 */  false, false, false, false, false, false, false, false, false, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, true, false, false, false, false, false,
/* 30 */  false, false, false, false, false, false, false, false, false, false, false, true, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, true, true, false, false, false, false, false,
/* 31 */  false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false,
/* 32 */  false, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, true, false, false, false, false,
/* 33 */  false, false, false, true, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false,
/* 34 */  false, false, false, true, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false,
/* 35 */  false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, true, false, false, false, true, false,
/* 36 */  false, false, false, false, false, false, false, false, false, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, true, true, false, false, true, false, true, false, false, false, true, true
};

const ushort Handbook::__atomsSpecifing[37] =
{
    0, 28, 2, 0, 34, 5, 4, 7, 8, 7,
    10, 26, 27, 13, 10, 15, 16, 17, 15, 19,
    20, 21, 20, 23, 24, 35, 36, 27, 28, 26,
    27, 25, 32, 33, 34, 35, 36
};

const ushort Handbook::__hToActives[37] =
{
    // TODO: проверить правила перехода (15 :: C:i=) в (16 :: *C=), в настоящий момент руками изменена цифра!
    28, 2, 2, 1, 5, 5, 5, 8, 8, 8,
    10, 12, 13, 13, 11, 16, 17, 17, 16, 19,
    21, 21, 21, 23, 24, 26, 27, 13, 2, 30,
    13, 29, 32, 33, 5, 36, 27
};

const ushort Handbook::__hOnAtoms[37] =
{
    2, 1, 0, 2, 1, 0, 1, 1, 0, 1,
    3, 2, 1, 0, 3, 2, 1, 0, 2, 0,
    1, 0, 1, 0, 0, 3, 2, 1, 1, 2,
    1, 3, 0, 0, 1, 3, 2
};

const ushort Handbook::__activesToH[37] =
{
    0, 3, 1, 3, 4, 6, 6, 7, 9, 9,
    10, 14, 11, 12, 14, 15, 18, 16, 18, 19,
    20, 22, 22, 23, 24, 25, 25, 26, 0, 31,
    29, 31, 32, 33, 34, 35, 35
};

const ushort Handbook::__activesOnAtoms[37] =
{
    0, 1, 2, 0, 0, 1, 0, 0, 1, 0,
    0, 1, 2, 3, 0, 0, 1, 2, 0, 0,
    0, 1, 0, 0, 0, 0, 1, 2, 1, 1,
    2, 0, 0, 0, 0, 0, 1
};

Handbook::DMC Handbook::__mc;

PhaseBoundary Handbook::__amorph;

Handbook::SKeeper Handbook::__specificKeepers[THREADS_NUM];
Handbook::LKeeper Handbook::__lateralKeepers[THREADS_NUM];
Scavenger Handbook::__scavengers[THREADS_NUM];

Handbook::DMC &Handbook::mc()
{
    return __mc;
}

PhaseBoundary &Handbook::amorph()
{
    return __amorph;
}

Handbook::SKeeper &Handbook::specificKeeper()
{
    return selectForThread(__specificKeepers);
}

Handbook::LKeeper &Handbook::lateralKeeper()
{
    return selectForThread(__lateralKeepers);
}

Scavenger &Handbook::scavenger()
{
    return selectForThread(__scavengers);
}

bool Handbook::atomIs(ushort complexType, ushort typeOf)
{
    assert(atomsNum > complexType);
    assert(atomsNum > typeOf);
    return __atomsAccordance[atomsNum * complexType + typeOf];
}

ushort Handbook::specificate(ushort type)
{
    assert(atomsNum > type);
    return __atomsSpecifing[type];
}
