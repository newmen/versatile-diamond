#ifndef SOUL_H
#define SOUL_H

#include "queue_item.h"

namespace vd {

class Soul : public QueueItem
{
    const Amorph* _amorph;
    const Crystal* _crystal;
    bool _isDataCopied = false;

public:
    Soul(const Amorph* amorph, const Crystal* crystal) : _amorph(amorph), _crystal(crystal) {}

    void copyData() override;
    void saveData(double, double) override;
    const Amorph *amorph() override;
    const Crystal *crystal() override;
    bool isEmpty() override { return true; }

    ~Soul();
};

}

#endif // SOUL_H
