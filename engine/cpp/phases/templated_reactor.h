#ifndef TEMPLATED_REACTOR_H
#define TEMPLATED_REACTOR_H

namespace vd
{

template <class AmorphType, class CrystalType>
class TemplatedReactor
{
protected:
    AmorphType *_amorph;
    CrystalType *_crystal;

    TemplatedReactor(AmorphType *amorph, CrystalType *crystal) :
        _amorph(amorph), _crystal(crystal) {}

public:
    template <class L> void eachAtom(const L &lambda) const;

private:
    TemplatedReactor(const TemplatedReactor &) = delete;
    TemplatedReactor(TemplatedReactor &&) = delete;
    TemplatedReactor &operator = (const TemplatedReactor &) = delete;
    TemplatedReactor &operator = (TemplatedReactor &&) = delete;
};

//////////////////////////////////////////////////////////////////////////////////////

template <class A, class C>
template <class L>
void TemplatedReactor<A, C>::eachAtom(const L &lambda) const
{
    _crystal->eachAtom(lambda);
    _amorph->eachAtom(lambda);
}

}

#endif // TEMPLATED_REACTOR_H
