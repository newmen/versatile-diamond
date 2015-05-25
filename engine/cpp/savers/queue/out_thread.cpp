#include "out_thread.h"

namespace vd
{

OutThread::OutThread()
{
    pthread_create(&_thread, nullptr, OutThread::thread_func, (void*)this);
}

int OutThread::wait()
{
    return pthread_join(_thread, nullptr);
}

void *OutThread::thread_func(void *d)
{
    static_cast<OutThread *>(d)->run();
    return nullptr;
}


}
