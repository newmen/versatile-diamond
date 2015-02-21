#ifndef SOUL_H
#define SOUL_H

#include "queue_item.h"

namespace vd {

class Soul : public QueueItem
{
    Amorph* _amorph;
    Crystal* _crystal;
    bool _isDataCopied = false;

public:
    Soul(Amorph* amorph, Crystal* crystal) : _amorph(amorph), _crystal(crystal) {}

    void copyData();
    void saveData();
    Amorph* amorph();
    Crystal* crystal();
    bool isEmpty() { return true; }
};

}

#endif // SOUL_H
