#ifndef THREAD_H
#define THREAD_H

#include <pthread.h>

namespace vd
{

class Thread
{
private:
    pthread_t thread;

    Thread(const Thread& copy);         // copy constructor denied
    static void *thread_func(void *d)
    {
        ((Thread *)d)->run();
        return NULL;
    }

public:
    Thread() {}
    virtual ~Thread() {}

    virtual void run() = 0;

    int start()
    {
        return pthread_create(&thread, NULL, Thread::thread_func, (void*)this);
    }

    int wait()
    {
        return pthread_join(thread, NULL);
    }
};

}

#endif // THREAD_H
