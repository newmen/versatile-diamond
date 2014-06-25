#ifndef SYMMETRIC_H
#define SYMMETRIC_H

#include "../tools/common.h"
#include "parent_spec.h"

namespace vd
{

template <class OriginalS, class... SymmetricSs>
class Symmetric : public OriginalS
{
    enum : ushort { SYMMETRICS_NUM = sizeof...(SymmetricSs) };
    ParentSpec *_symmetrics[SYMMETRICS_NUM];

protected:
    template <class... Args> Symmetric(Args... args) : OriginalS(args...) {}

public:
    void setUnvisited() override;
    void findChildren() override;

    void store() override;
    void remove() override;

    template <class L> void eachSymmetry(const L &lambda);

private:
    template <class HeadS> void createSymmetrics(ushort index);
    template <class FirstS, class SecondS, class... TailSs> void createSymmetrics(ushort index);
};

//////////////////////////////////////////////////////////////////////////////////////

template <class OS, class... SSS>
void Symmetric<OS, SSS...>::setUnvisited()
{
    for (ushort i = 0; i < SYMMETRICS_NUM; ++i)
    {
        _symmetrics[i]->setUnvisited();
    }
    OS::setUnvisited();
}

template <class OS, class... SSS>
void Symmetric<OS, SSS...>::findChildren()
{
    for (ushort i = 0; i < SYMMETRICS_NUM; ++i)
    {
        _symmetrics[i]->findChildren();
    }
    OS::findChildren();
}

template <class OS, class... SSS>
void Symmetric<OS, SSS...>::store()
{
    createSymmetrics<SSS...>(0);
    OS::store();
}

template <class OS, class... SSS>
void Symmetric<OS, SSS...>::remove()
{
    for (ushort i = 0; i < SYMMETRICS_NUM; ++i)
    {
        _symmetrics[i]->remove();
    }
    OS::remove();
}

template <class OS, class... SSS>
template <class L>
void Symmetric<OS, SSS...>::eachSymmetry(const L &lambda)
{
    lambda(this);
    for (ushort i = 0; i < SYMMETRICS_NUM; ++i)
    {
        lambda(_symmetrics[i]);
    }
}

template <class OS, class... SSS>
template <class HS>
void Symmetric<OS, SSS...>::createSymmetrics(ushort index)
{
    _symmetrics[index] = new HS(this);
}

template <class OS, class... SSS>
template <class HS, class SS, class... TSS>
void Symmetric<OS, SSS...>::createSymmetrics(ushort index)
{
    createSymmetrics<HS>(index);
    createSymmetrics<SS, TSS...>(index + 1);
}

}

#endif // SYMMETRIC_H
