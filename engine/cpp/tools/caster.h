#ifndef CASTER_H
#define CASTER_H

#include <assert.h>

namespace vd
{

template <class T, class F>
inline T cast_to(F from)
{
    if (from == nullptr) return nullptr;

#ifdef DEBUG
    auto dynamicResult = dynamic_cast<T>(from);
    assert(dynamicResult);
    return dynamicResult;
#else
    return static_cast<T>(from);
#endif // DEBUG
}

}

#endif // CASTER_H
