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

    SavingAmorph *_copyAmorph = nullptr;
    SavingCrystal *_copyCrystal = nullptr;

public:
    Soul(const Amorph *amorph, const Crystal *crystal) : _origAmorph(amorph), _origCrystal(crystal) {}
    ~Soul();

    void saveData(double, double, const char *) override {}
    void copyData() override;
    bool isEmpty() const override { return true; }

protected:
    const SavingAmorph *amorph() override { return _copyAmorph; }
    const SavingCrystal *crystal() override { return _copyCrystal; }
    void saveData(const SavingData &) const override {}
};

}

#endif // SOUL_H
