#include "frame.h"

namespace vd
{

Frame::Frame(Job *rootJob, BaseSaver *saver) :
    _rootJob(rootJob), _saver(saver)
{
}

Frame::~Frame()
{
    delete _rootJob;
}

void Frame::copyState()
{
    _rootJob->copyState();
}

void Frame::apply()
{
    _rootJob->apply();
    _saver->save(reactor());
}

const SavingReactor *Frame::reactor()
{
    return _rootJob->reactor();
}

}
