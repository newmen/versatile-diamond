#ifndef OUT_THREAD_H
#define OUT_THREAD_H

#include <pthread.h>

namespace vd
{

class OutThread
{
    pthread_t _thread;

public:
    virtual ~OutThread() {}

    int wait();
    virtual void run() = 0;
    void stopThread();

private:
    OutThread(const OutThread& copy);
    static void *thread_func(void *d);

protected:
    OutThread();
};

}

#endif // OUT_THREAD_H
