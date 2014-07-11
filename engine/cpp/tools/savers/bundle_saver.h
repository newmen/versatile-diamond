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

    void writeToFrom(std::ostream &os, Atom *atom, double currentTime, const Detector *detector) const;
};

/////////////////////////////////////////////////////////////////////////////////////////

template <class A, class F>
void BundleSaver<A, F>::writeToFrom(std::ostream &os, Atom *atom, double currentTime, const Detector *detector) const
{
    A acc(detector);
    accumulateToFrom(&acc, atom);
    const F format(*this, acc);
    format.render(os, currentTime);
}

}

#endif // BUNDLE_SAVER_H
