#ifndef COUNTER_WHITH_SAVER
#define COUNTER_WHITH_SAVER

#include "saver_counter.h"

namespace vd
{

template <class S>
class CounterWhithSaver : public SaverCounter
{
    S *_saver;

public:
    CounterWhithSaver(double step, S *saver) : SaverCounter(step), _saver(saver) {}
    ~CounterWhithSaver();

    S *saver() { return _saver; }
};

////////////////////////////////////////////////////////////////////////////////

template <class S>
CounterWhithSaver<S>::~CounterWhithSaver()
{
    delete _saver;
}

}

#endif // COUNTER_WHITH_SAVER

