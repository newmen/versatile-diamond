#ifndef PROGRESS_SAVER_H
#define PROGRESS_SAVER_H

#include "../phases/saving_amorph.h"
#include "../phases/saving_crystal.h"
#include <iostream>

namespace vd
{

template <class HB>
class ProgressSaver
{
public:
    ProgressSaver() = default;
    ~ProgressSaver() = default;

    void printShortState(const SavingCrystal *crystal, const SavingAmorph *amorph, double allTime, double currentTime);

private:
    double activesRatio(const SavingCrystal *crystal, const SavingAmorph *amorph) const;
};

//////////////////////////////////////////////////////////////////////////////////////

template <class HB>
void ProgressSaver<HB>::printShortState(const SavingCrystal *crystal, const SavingAmorph *amorph, double allTime, double currentTime)
{
    std::cout.width(10);
    std::cout << 100 * currentTime / allTime << " %";
    std::cout.width(10);
    std::cout << crystal->countAtoms();
    std::cout.width(10);
    std::cout << amorph->countAtoms();
    std::cout.width(10);
    std::cout << 100 * activesRatio(crystal, amorph) << " %";
    std::cout.width(20);
    std::cout << HB::mc().totalTime() << " (s)";
    std::cout.width(20);
    std::cout << HB::mc().totalRate() << " (1/s)" << std::endl;
}

template <class HB>
double ProgressSaver<HB>::activesRatio(const SavingCrystal *crystal, const SavingAmorph *amorph) const
{
    uint actives = 0;
    uint hydrogens = 0;
    auto lambda = [&actives, &hydrogens](const SavingAtom *atom) {
        actives += HB::activesFor(atom->type());
        hydrogens += HB::hydrogensFor(atom->type());
    };

    amorph->eachAtom(lambda);
    crystal->eachAtom(lambda);
    return (double)actives / (actives + hydrogens);
}

}

#endif // PROGRESS_SAVER_H
