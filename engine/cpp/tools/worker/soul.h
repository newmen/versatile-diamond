#ifndef SOUL_H
#define SOUL_H

#include "../../phases/reactor.h"
#include "job.h"

namespace vd
{

template <class HB>
class Soul : public Job
{
    const Reactor<HB> *_origReactor;
    const SavingReactor *_savingReactor = nullptr;

public:
    Soul(const Reactor<HB> *reactor) : _origReactor(reactor) {}
    ~Soul();

    void copyState() override;
    void apply() override {}

    bool isEmpty() const override { return true; }

    const SavingReactor *reactor() override { return _savingReactor; }
};

//////////////////////////////////////////////////////////////////////////////////////

template <class HB>
Soul<HB>::~Soul()
{
    delete _savingReactor;
}

template <class HB>
void Soul<HB>::copyState()
{
    _savingReactor = _origReactor->copy();
}

}

#endif // SOUL_H
