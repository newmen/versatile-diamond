#include "dictionary.h"
#include <omp.h>

#include <assert.h>

const uint Dictionary::__atomsNum = 32;
const bool Dictionary::__atomsAccordance[] = {
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

const ushort Dictionary::__atomsSpecifing[] =
{
      0, 28, 2, 0, 4, 5, 4, 7, 8, 7, 10, 26, 27, 13, 10, 15, 16, 17, 15, 19, 20, 21, 20, 23, 24, 25, 26, 27, 28, 26, 27, 25
};


const ushort Dictionary::__activesOnAtoms[] =
{
    0, 1, 2, 0, 0, 1, 0, 0, 1, 0, 0, 1, 2, 3, 0, 0, 1, 2, 0, 0, 0, 1, 0, 0, 0, 0, 1, 2, 1, 1, 2, 0
};
const ushort Dictionary::__hOnAtoms[] =
{
    2, 1, 0, 2, 1, 0, 1, 1, 0, 1, 3, 2, 1, 0, 3, 2, 1, 0, 2, 0, 1, 0, 1, 0, 0, 3, 2, 1, 1, 2, 1, 3
};

const ushort Dictionary::__activesToH[] =
{
    0, 3, 1, 3, 4, 6, 6, 7, 9, 9, 10, 14, 11, 12, 14, 15, 18, 16, 18, 19, 20, 22, 22, 23, 24, 25, 25, 26, 0, 31, 29, 31
};
const ushort Dictionary::__hToActives[] =
{
    28, 2, 2, 1, 5, 5, 5, 8, 8, 8, 10, 12, 13, 13, 11, 15, 17, 17, 16, 19, 21, 21, 21, 23, 24, 26, 27, 13, 2, 30, 13, 29
};

DMC Dictionary::__mc;
DMC &Dictionary::mc()
{
    return __mc;
}

bool Dictionary::atomIs(uint complexType, uint typeOf)
{
    assert(__atomsNum > complexType);
    assert(__atomsNum > typeOf);
    return __atomsAccordance[__atomsNum * complexType + typeOf];
}

ushort Dictionary::specificate(uint type)
{
    assert(__atomsNum > type);
    return __atomsSpecifing[type];
}

ushort Dictionary::activesNum(uint type)
{
    assert(__atomsNum > type);
    return __activesOnAtoms[type];
}

ushort Dictionary::hNum(uint type)
{
    assert(__atomsNum > type);
    return __hOnAtoms[type];
}

ushort Dictionary::activesToH(uint type)
{
    assert(__atomsNum > type);
    return __activesToH[type];
}

ushort Dictionary::hToActives(uint type)
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

void Dictionary::purge()
{
//    clearNews();
    ::purge(&__bridges);
    ::purge(&__dimers);
}

uint Dictionary::specsNum()
{
    return __bridges.size() + __dimers.size();
}

std::unordered_set<Bridge *> Dictionary::__bridges;
std::unordered_set<Dimer *> Dictionary::__dimers;
