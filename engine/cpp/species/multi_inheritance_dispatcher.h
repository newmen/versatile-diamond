#ifndef MULTI_INHERITANCE_DISPATCHER_H
#define MULTI_INHERITANCE_DISPATCHER_H

#include "base_spec.h"

namespace vd
{

template <class B>
struct MultiInheritanceDispatcher : public B {};

template <>
struct MultiInheritanceDispatcher<BaseSpec> : virtual public BaseSpec {};

}

#endif // MULTI_INHERITANCE_DISPATCHER_H
