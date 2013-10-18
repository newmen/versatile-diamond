#include "handbook.h"
#include <omp.h>

#include <assert.h>

const ushort Handbook::__atomsNum = 32;
const bool Handbook::__atomsAccordance[] = {
    true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, true, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, true, false, true, false, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, true, false, false, false, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, true, false, true, false, false, false, false, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, true, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, true, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false, true, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, true, false, false, false, false, false, false, false, false, false,
    false, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, true, false, false, false, false, false, false, false, false, false,
    false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false,
    false, false, false, true, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, true, true, false, false, false, false, false, false, false, false,
    false, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, true,
    false, false, false, false, false, false, false, false, false, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, true, false, false, true, false, true,
    false, false, false, false, false, false, false, false, false, false, false, true, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, true, false, true, true, true,
    false, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false, true, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, true,
    false, false, false, false, false, false, false, false, false, false, false, true, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, true, true,
    false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true
};

const ushort Handbook::__atomsSpecifing[] =
{
      0, 28, 2, 0, 4, 5, 4, 7, 8, 7, 10, 26, 27, 13, 10, 15, 16, 17, 15, 19, 20, 21, 20, 23, 24, 25, 26, 27, 28, 26, 27, 25
};

const ushort Handbook::__activesOnAtoms[] =
{
    0, 1, 2, 0, 0, 1, 0, 0, 1, 0, 0, 1, 2, 3, 0, 0, 1, 2, 0, 0, 0, 1, 0, 0, 0, 0, 1, 2, 1, 1, 2, 0
};
const ushort Handbook::__hOnAtoms[] =
{
    2, 1, 0, 2, 1, 0, 1, 1, 0, 1, 3, 2, 1, 0, 3, 2, 1, 0, 2, 0, 1, 0, 1, 0, 0, 3, 2, 1, 1, 2, 1, 3
};

const ushort Handbook::__activesToH[] =
{
    0, 3, 1, 3, 4, 6, 6, 7, 9, 9, 10, 14, 11, 12, 14, 15, 18, 16, 18, 19, 20, 22, 22, 23, 24, 25, 25, 26, 0, 31, 29, 31
};
const ushort Handbook::__hToActives[] =
{
    28, 2, 2, 1, 5, 5, 5, 8, 8, 8, 10, 12, 13, 13, 11, 15, 17, 17, 16, 19, 21, 21, 21, 23, 24, 26, 27, 13, 2, 30, 13, 29
};

DMC Handbook::__mc;
DMC &Handbook::mc()
{
    return __mc;
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

ushort Handbook::activesNum(ushort type)
{
    assert(__atomsNum > type);
    return __activesOnAtoms[type];
}

ushort Handbook::hNum(uint type)
{
    assert(__atomsNum > type);
    return __hOnAtoms[type];
}

ushort Handbook::activesToH(uint type)
{
    assert(__atomsNum > type);
    return __activesToH[type];
}

ushort Handbook::hToActives(uint type)
{
    assert(__atomsNum > type);
    return __hToActives[type];
}

//std::vector<BaseSpec *> Dictionary::__newSpecs;
//void Dictionary::addNew(BaseSpec *spec)
//{
//#pragma omp critical
//    __newSpecs.push_back(spec);
//}

//void Dictionary::clearNews()
//{
//    __newSpecs.clear();
//    if (__newSpecs.max_size() > 100) __newSpecs.resize(10);
//}

void Handbook::purge()
{
//    clearNews();
    ::purge(&__bridges);
    ::purge(&__dimers);
}

uint Handbook::specsNum()
{
    return __bridges.size() + __dimers.size();
}

std::unordered_set<Bridge *> Handbook::__bridges;
std::unordered_set<Dimer *> Handbook::__dimers;
