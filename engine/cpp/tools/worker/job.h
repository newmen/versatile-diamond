#ifndef JOB_H
#define JOB_H

#include "../../phases/saving_reactor.h"

namespace vd
{

class Job
{
protected:
    Job() = default;

public:
    virtual ~Job() {}

    virtual bool isEmpty() const { return false; } // by default
    virtual void copyState() = 0;
    virtual void apply() = 0;

    virtual const SavingReactor *reactor() = 0;

private:
    Job(const Job &) = delete;
    Job(Job &&) = delete;
    Job &operator = (const Job &) = delete;
    Job &operator = (Job &&) = delete;
};

}

#endif // JOB_H
