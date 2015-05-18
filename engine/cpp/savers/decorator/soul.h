#ifndef SOUL_H
#define SOUL_H

#include "queue_item.h"
#include "../../phases/saving_amorph.h"

namespace vd
{

class Soul : public QueueItem
{
    const Amorph *_origAmorph;
    const Crystal *_origCrystal;

    const SavingAmorph *_copyAmorph = nullptr;
    const SavingCrystal *_copyCrystal = nullptr;

    typedef std::tuple<const SavingCrystal *, const SavingAmorph *> SavingPhases;
    SavingPhases copyAtoms(const Crystal *crystal, const Amorph *amorph) const;

public:
    Soul(const Amorph *amorph, const Crystal *crystal) : _origAmorph(amorph), _origCrystal(crystal) {}
    ~Soul();

    void saveData(double, double, const char *) override {}
    bool isEmpty() override { return true; }
    void copyData() override;

protected:
    const SavingAmorph *amorph() override { return _copyAmorph; }
    const SavingCrystal *crystal() override { return _copyCrystal; }
    void saveData(const SavingData &) override {}
};

}

#endif // SOUL_H
