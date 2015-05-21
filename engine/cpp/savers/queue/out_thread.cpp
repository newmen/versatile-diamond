#include "out_thread.h"

namespace vd
{

int OutThread::init()
{
    return pthread_create(&_thread, NULL, OutThread::thread_func, (void*)this);
}

int OutThread::wait()
{
    return pthread_join(_thread, NULL);
}

void *OutThread::thread_func(void *d)
{
    ((OutThread *)d)->run();
    return nullptr;
}

}
