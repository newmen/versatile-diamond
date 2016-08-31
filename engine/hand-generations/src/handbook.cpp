#include "handbook.h"

// TODO: move matrixes to separated tables.* instance
// 10 :: ~C:i~
// 32 :: -^C%d<
// 33 :: ~^C%d<
// 34 :: ^HC%d<
// 35 :: HC:i:u~
// 36 :: H*C:i:u~
// 37 :: ~*C:i~
// 38 :: ~**C~
const ushort Handbook::__atomsNum = 39;
const bool Handbook::__atomsAccordance[Handbook::__atomsNum * Handbook::__atomsNum] = {
/*  0 */ true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/*  1 */ false, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/*  2 */ true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false,
/*  3 */ false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/*  4 */ false, false, false, true, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/*  5 */ false, true, false, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/*  6 */ false, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/*  7 */ false, false, false, true, false, false, false, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/*  8 */ false, true, false, true, false, false, false, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/*  9 */ false, false, false, true, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 10 */ false, false, false, false, false, false, false, false, false, false, true, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 11 */ false, false, false, false, false, false, false, false, false, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 12 */ false, false, false, false, false, false, false, false, false, false, false, true, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 13 */ false, false, false, false, false, false, false, false, false, false, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, true, true, true, false, true, true, true, false, false, false, false, false, false, false,
/* 14 */ false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 15 */ false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 16 */ false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 17 */ false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 18 */ false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 19 */ false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 20 */ false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 21 */ false, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 22 */ false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 23 */ false, false, false, true, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 24 */ false, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
/* 25 */ false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, true, false, false, false, false, false, false, false,
/* 26 */ false, false, false, false, false, false, false, false, false, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, true, true, false, false, true, false, true, false, false, false, false, false, false, false,
/* 27 */ false, false, false, false, false, false, false, false, false, false, false, true, true, false, true, false, false, false, false, false, false, false, false, false, false, true, true, true, false, true, true, true, false, false, false, true, true, false, false,
/* 28 */ true, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false,
/* 29 */ false, false, false, false, false, false, false, false, false, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, true, false, false, false, false, false, false, false,
/* 30 */ false, false, false, false, false, false, false, false, false, false, false, true, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, true, true, false, false, false, false, false, false, false,
/* 31 */ false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false,
/* 32 */ false, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false,
/* 33 */ false, false, false, true, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false,
/* 34 */ false, false, false, true, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false,
/* 35 */ false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, true, false, false, false, true, false, false, false,
/* 36 */ false, false, false, false, false, false, false, false, false, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, true, true, false, false, true, false, true, false, false, false, true, true, false, false,
/* 37 */ false, false, false, false, false, false, false, false, false, false, true, true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false,
/* 38 */ false, false, false, false, false, false, false, false, false, false, true, true, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, true
};

const ushort Handbook::__atomsSpecifing[Handbook::__atomsNum] =
{
    0, 28, 2, 0, 34, 5, 34, 7, 8, 7,
    10, 36, 27, 13, 35, 15, 16, 17, 15, 19,
    20, 21, 20, 23, 24, 35, 36, 27, 28, 36,
    27, 35, 32, 33, 34, 35, 36, 37, 38
};

const ushort Handbook::__hToActives[Handbook::__atomsNum] =
{
    28, 2, 2, 1, 5, 5, 5, 8, 8, 8,
    37, 12, 13, 13, 11, 16, 17, 17, 16, 19,
    21, 21, 21, 23, 24, 26, 27, 13, 2, 30,
    13, 29, 32, 33, 5, 36, 27, 38, 38
};

const ushort Handbook::__hOnAtoms[Handbook::__atomsNum] =
{
    2, 1, 0, 2, 1, 0, 1, 1, 0, 1,
    2, 2, 1, 0, 3, 2, 1, 0, 2, 0,
    1, 0, 1, 0, 0, 3, 2, 1, 1, 2,
    1, 3, 0, 0, 1, 3, 2, 1, 0
};

const ushort Handbook::__activesToH[Handbook::__atomsNum] =
{
    0, 3, 1, 3, 4, 6, 6, 7, 9, 9,
    10, 14, 11, 12, 14, 15, 18, 16, 18, 19,
    20, 22, 22, 23, 24, 25, 25, 26, 0, 31,
    29, 31, 32, 33, 34, 35, 35, 10, 37
};

const ushort Handbook::__activesOnAtoms[Handbook::__atomsNum] =
{
    0, 1, 2, 0, 0, 1, 0, 0, 1, 0,
    0, 1, 2, 3, 0, 0, 1, 2, 0, 0,
    0, 1, 0, 0, 0, 0, 1, 2, 1, 1,
    2, 0, 0, 0, 0, 0, 1, 1, 2
};

Handbook::DMC Handbook::__mc;
Handbook::DMC &Handbook::mc()
{
    return __mc;
}

Handbook::SurfaceAmorph Handbook::__amorph;
Handbook::SurfaceAmorph &Handbook::amorph()
{
    return __amorph;
}

Handbook::SKeeper Handbook::__specificKeeper;
Handbook::SKeeper &Handbook::specificKeeper()
{
    return __specificKeeper;
}

Handbook::LKeeper Handbook::__lateralKeeper;
Handbook::LKeeper &Handbook::lateralKeeper()
{
    return __lateralKeeper;
}

Scavenger Handbook::__scavenger;
Scavenger &Handbook::scavenger()
{
    return __scavenger;
}

const ushort Handbook::__regularAtomsNum = 1;
const ushort Handbook::__regularAtomsTypes[Handbook::__regularAtomsNum] = { 24 };
bool Handbook::isRegular(ushort type)
{
    bool b = false;
    for (int i = 0; i < __regularAtomsNum; ++i)
    {
        b = b || type == __regularAtomsTypes[i];
    }

    return b;
}

ushort Handbook::activesFor(ushort type)
{;
    assert(type < __atomsNum);
    return __activesOnAtoms[type];
}

ushort Handbook::hydrogensFor(ushort type)
{
    assert(type < __atomsNum);
    return __hOnAtoms[type];
}

ushort Handbook::hToActivesFor(ushort type)
{
    assert(type < __atomsNum);
    return __hToActives[type];
}

ushort Handbook::activesToHFor(ushort type)
{
    assert(type < __atomsNum);
    return __activesToH[type];
}

bool Handbook::atomIs(ushort complexType, ushort typeOf)
{
    assert(__atomsNum > complexType);
    assert(__atomsNum > typeOf);
    return __atomsAccordance[__atomsNum * complexType + typeOf];
}

ushort Handbook::specificate(ushort type)
{
    assert(__atomsNum > type);
    return __atomsSpecifing[type];
}
