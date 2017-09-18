#ifndef PROGRESS_SAVER_H
#define PROGRESS_SAVER_H

#include <iostream>
#include "base_saver.h"

namespace vd
{

template <class HB>
class ProgressSaver : public BaseSaver
{
public:
    template <class... Args> ProgressSaver(Args... args) : BaseSaver(args...) {}

    void save(const SavingReactor *reactor) override;

private:
    double activesRatio(const SavingReactor *reactor) const;
};

//////////////////////////////////////////////////////////////////////////////////////

template <class HB>
void ProgressSaver<HB>::save(const SavingReactor *reactor)
{
    std::cout.width(10);
    std::cout << 100 * reactor->currentTime() / config()->totalTime() << " %";
    std::cout.width(10);
    std::cout << reactor->crystal()->countAtoms();
    std::cout.width(10);
    std::cout << reactor->amorph()->countAtoms();
    std::cout.width(10);
    std::cout << 100 * activesRatio(reactor) << " %";
    std::cout.width(20);
    std::cout << reactor->currentTime() << " (s)";
    std::cout.width(20);
    std::cout << reactor->totalRate() << " (1/s)" << std::endl;
}

template <class HB>
double ProgressSaver<HB>::activesRatio(const SavingReactor *reactor) const
{
    uint actives = 0;
    uint hydrogens = 0;
    reactor->eachAtom([&actives, &hydrogens](const SavingAtom *atom) {
        actives += HB::activesFor(atom->type());
        hydrogens += HB::hydrogensFor(atom->type());
    });

    return (double)actives / (actives + hydrogens);
}

}

#endif // PROGRESS_SAVER_H
