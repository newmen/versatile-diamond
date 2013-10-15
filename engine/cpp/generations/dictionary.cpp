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


bool Dictionary::atomIs(uint complexType, uint typeOf)
{
    assert(__atomsNum > complexType);
    assert(__atomsNum > typeOf);
    return __atomsAccordance[__atomsNum * complexType + typeOf];
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
