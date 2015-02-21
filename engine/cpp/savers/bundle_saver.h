#ifndef BUNDLE_SAVER_H
#define BUNDLE_SAVER_H

#include "volume_saver.h"

namespace vd
{

template <class A, class F>
class BundleSaver : public VolumeSaver
{
protected:
    template <class... Args> BundleSaver(Args... args) : VolumeSaver(args...) {}

    void saveTo(std::ostream &os, double currentTime, const Amorph *amorph, const Crystal *crystal, const Detector *detector) const;
};

/////////////////////////////////////////////////////////////////////////////////////////

template <class A, class F>
void BundleSaver<A, F>::saveTo(std::ostream &os, double currentTime, const Amorph *amorph, const Crystal *crystal, const Detector *detector) const
{
    A acc(detector);
    auto lambda = [&acc](const Atom *atom) {
        atom->eachNeighbour([&acc, atom](Atom *nbr) {
            acc.addBondedPair(atom, nbr);
        });
    };

    amorph->eachAtom(lambda);
    crystal->eachAtom(lambda);

    const F format(*this, acc);
    format.render(os, currentTime);
}

}

#endif // BUNDLE_SAVER_H
