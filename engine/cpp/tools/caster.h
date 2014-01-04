#ifndef CASTER_H
#define CASTER_H

#include <assert.h>

namespace vd
{

template <class T, class F>
inline T cast_to(F from)
{
    if (from == nullptr) return nullptr;

    auto dynamicResult = dynamic_cast<T>(from);
    assert(dynamicResult);
    return dynamicResult;
}

}

#endif // CASTER_H
