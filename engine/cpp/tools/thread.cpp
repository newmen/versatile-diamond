#include "thread.h"

namespace vd
{

int Thread::start()
{
    return pthread_create(&_thread, NULL, Thread::thread_func, (void*)this);
}

int Thread::wait()
{
    return pthread_join(_thread, NULL);
}

void *Thread::thread_func(void *d)
{
    ((Thread *)d)->run();
    return NULL;
}

}
