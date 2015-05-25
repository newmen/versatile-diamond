#ifndef DUMPBUNDLESAVER_H
#define DUMPBUNDLESAVER_H

//#include "dump_saver.h"

//namespace vd
//{

//template <class A, class F>
//class DumpBundleSaver : public DumpSaver
//{
//protected:
//    template <class... Args> DumpBundleSaver(Args... args) : VolumeSaver(args...) {}

//    void saveTo(std::ostream &os, double currentTime, const SavingAmorph *amorph, const SavingCrystal *crystal, const Detector *detector) const;
//};

///////////////////////////////////////////////////////////////////////////////////////////

//template <class A, class F>
//void DumpBundleSaver<A, F>::saveTo(std::ostream &os, double currentTime, const SavingAmorph *amorph, const SavingCrystal *crystal, const Detector *detector) const
//{
//    A acc(detector);
//    auto lambda = [&acc](const SavingAtom *atom) {
//        atom->eachNeighbour([&acc, atom](SavingAtom *nbr) {
//            acc.addBondedPair(atom, nbr);
//        });
//    };

//    amorph->eachAtom(lambda);
//    crystal->eachAtom(lambda);

//    const F format(*this, acc);
//    format.render(os, currentTime);
//}

//}

#endif // DUMPBUNDLESAVER_H
