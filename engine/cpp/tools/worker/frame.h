#ifndef FRAME_H
#define FRAME_H

#include "../../savers/base_saver.h"
#include "job.h"

namespace vd
{

class Frame : public Job
{
    Job *_rootJob;
    BaseSaver *_saver;

public:
    Frame(Job *rootJob, BaseSaver *saver);
    ~Frame();

    void copyState() override;
    void apply() override;

    const SavingReactor *reactor() override;
};

}

#endif // FRAME_H
