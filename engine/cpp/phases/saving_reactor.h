#ifndef SAVING_REACTOR_H
#define SAVING_REACTOR_H

#include "templated_reactor.h"
#include "saving_amorph.h"
#include "saving_crystal.h"

namespace vd
{

class SavingReactor : public TemplatedReactor<SavingAmorph, SavingCrystal>
{
    const double _currentTime;
    const double _totalRate;

public:
    SavingReactor(SavingAmorph *amorph,
                  SavingCrystal *crystal,
                  double currentTime,
                  double totalRate) :
        TemplatedReactor(amorph, crystal),
        _currentTime(currentTime),
        _totalRate(totalRate) {}
    ~SavingReactor();

    const SavingAmorph *amorph() const { return _amorph; }
    const SavingCrystal *crystal() const { return _crystal; }

    double currentTime() const { return _currentTime; }
    double totalRate() const { return _totalRate; }
};

}

#endif // SAVING_REACTOR_H
