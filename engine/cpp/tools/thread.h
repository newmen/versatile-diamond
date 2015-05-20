#ifndef THREAD_H
#define THREAD_H

#include <pthread.h>

namespace vd
{

class Thread
{
    pthread_t _thread;

public:
    virtual ~Thread() {}

    int init();
    int wait();
    virtual void run() = 0;

private:
    Thread(const Thread& copy);
    static void *thread_func(void *d);

protected:
    Thread() {}
};

}

#endif // THREAD_H
