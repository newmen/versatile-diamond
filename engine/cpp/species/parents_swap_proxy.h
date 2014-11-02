#ifndef PARENT_PROXY_H
#define PARENT_PROXY_H

#include "../atoms/atom.h"
#include "../tools/typed.h"

namespace vd
{

template <class OS, class SS, ushort ST>
class ParentsSwapProxy : public Typed<SS, ST>
{
    typedef Typed<SS, ST> ParentType;

protected:
    template <class DS>
    ParentsSwapProxy(DS *original) :
        ParentType(static_cast<OS *>(original->parent())) {}
};

}

#endif // PARENT_PROXY_H
