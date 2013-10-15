#include "dictionary.h"
#include <omp.h>

#include <assert.h>

const uint Dictionary::__atomsNum = 21;
const bool Dictionary::__atomsAccordance[] = {
    true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    true, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    true, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
    true, false, true, false, false, false, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false,
    true, true, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false,
    true, false, false, false, false, false, true, false, false, true, false, false, false, false, false, false, true, false, false, false, false,
    true, false, false, false, false, false, true, false, false, false, true, false, false, false, false, false, false, false, false, false, false,
    true, true, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false,
    false, false, false, true, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false,
    false, false, false, true, false, false, false, false, false, false, false, false, false, true, true, false, false, true, false, false, false,
    false, false, false, true, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false,
    true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, true, false, false, false, false,
    true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false,
    false, false, false, true, false, false, false, false, false, false, false, false, false, false, true, false, false, true, false, false, false,
    false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false,
    true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, true, false,
    true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true
};

const ushort Dictionary::__activesOnAtoms[] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 0 };
const ushort Dictionary::__hOnAtoms[] = { 2, 1, 1, 3, 2, 0, 1, 0, 0, 0, 1, 1, 3, 2, 2, 1, 1, 2, 2, 0, 2 };

const short Dictionary::__activesToH[] = { -1, -1, -1, -1, -1, -1, -1, -1, -1, 6, -1, -1, -1, 12, 3, 20, 0, -1, -1, 1, -1 };
const short Dictionary::__hToActives[] = { 16, 19, -1, 14, -1, -1, 9, -1, -1, -1, -1, -1, 13, -1, -1, -1, -1, -1, -1, -1, 15 };

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

short Dictionary::activesToH(uint type)
{
    assert(__atomsNum > type);
    return __activesToH[type];
}

short Dictionary::hToActives(uint type)
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
