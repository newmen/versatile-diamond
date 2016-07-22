#ifndef SYMMETRIC_H
#define SYMMETRIC_H

#include "../tools/common.h"

namespace vd
{

template <class OriginalS, class FirstSymmetricS, class... OtherSymmetricSs>
class Symmetric : public OriginalS
{
    enum : ushort { SYMMETRICS_NUM = 1 + sizeof...(OtherSymmetricSs) };
    typename FirstSymmetricS::SymmetricType *_symmetrics[SYMMETRICS_NUM];

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

template <class OS, class FSS, class... OSSS>
void Symmetric<OS, FSS, OSSS...>::setUnvisited()
{
    for (ushort i = 0; i < SYMMETRICS_NUM; ++i)
    {
        _symmetrics[i]->setUnvisited();
    }
    OS::setUnvisited();
}

template <class OS, class FSS, class... OSSS>
void Symmetric<OS, FSS, OSSS...>::findChildren()
{
    for (ushort i = 0; i < SYMMETRICS_NUM; ++i)
    {
        // Symmetric specie can have own children which also should call findChildren() method
        _symmetrics[i]->findChildren();
    }
    OS::findChildren();
}

template <class OS, class FSS, class... OSSS>
void Symmetric<OS, FSS, OSSS...>::store()
{
    createSymmetrics<FSS, OSSS...>(0);
    OS::store();
}

template <class OS, class FSS, class... OSSS>
void Symmetric<OS, FSS, OSSS...>::remove()
{
    for (ushort i = 0; i < SYMMETRICS_NUM; ++i)
    {
        _symmetrics[i]->remove();
    }
    OS::remove();
}

template <class OS, class FSS, class... OSSS>
template <class L>
void Symmetric<OS, FSS, OSSS...>::eachSymmetry(const L &lambda)
{
    lambda(this);
    for (ushort i = 0; i < SYMMETRICS_NUM; ++i)
    {
        lambda(_symmetrics[i]);
    }
}

template <class OS, class FSS, class... OSSS>
template <class HS>
void Symmetric<OS, FSS, OSSS...>::createSymmetrics(ushort index)
{
    _symmetrics[index] = new HS(this);
}

template <class OS, class FSS, class... OSSS>
template <class HS, class SS, class... TSS>
void Symmetric<OS, FSS, OSSS...>::createSymmetrics(ushort index)
{
    createSymmetrics<HS>(index);
    createSymmetrics<SS, TSS...>(index + 1);
}

}

#endif // SYMMETRIC_H
