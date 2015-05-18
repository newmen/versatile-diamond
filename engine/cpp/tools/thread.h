#ifndef THREAD_H
#define THREAD_H

#include <pthread.h>

namespace vd
{

class Thread
{
    pthread_t _thread;

public:
    Thread() {}
    virtual ~Thread() {}

    int start();
    int wait();
    virtual void run() = 0;

private:
    Thread(const Thread& copy);
    static void *thread_func(void *d);

};

}

#endif // THREAD_H
