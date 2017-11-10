#ifndef RUNNER_H
#define RUNNER_H

#include <iostream>
#include <sys/time.h>
#include "../phases/reactor.h"
#include "worker/parallel_worker.h"
#include "config.h"
#include "tracker.h"
#include "process_mem_usage.h"
#include "define_print.h"

#define TRACK_EACH_STEP 10000
#define MC_SORT_EACH_STEP (TRACK_EACH_STEP * 5)

#ifdef ANY_PRINT
#define DEBUG_EACH_STEP TRACK_EACH_STEP
#endif // ANY_PRINT

namespace vd
{

template <class HB>
class Runner
{
    static volatile bool __terminate;

    const Config *_config;
    Reactor<HB> *_reactor;
    Tracker<HB> *_tracker;

    ParallelWorker _parallelWorker;

public:
    static void stop();

    Runner(const Config *config, Reactor<HB> *reactor, Tracker<HB> *tracker) :
        _config(config), _reactor(reactor), _tracker(tracker) {}

    void calculate();

private:
    Runner(const Runner &) = delete;
    Runner(Runner &&) = delete;
    Runner &operator = (const Runner &) = delete;
    Runner &operator = (Runner &&) = delete;

#ifdef JSONLOG
    void serializeStep(double time);
#endif // JSONLOG

    void firstSave();
    void storeIfNeed(double timeDelta, bool forseSave);
    void processJob(Job *job);

    double timestamp() const;

    void outputMemoryUsage(std::ostream &os) const;
    void printStat(double startTime, double stopTime, ullong steps) const;
};

//////////////////////////////////////////////////////////////////////////////////////

template <class HB>
volatile bool Runner<HB>::__terminate = false;

template <class HB>
void Runner<HB>::stop()
{
    __terminate = true;
}

#ifdef JSONLOG
template <class HB>
void Runner<HB>::serializeStep(double time)
{
    HB::stepsLogger().step(time, HB::mc().counts());
}
#endif // JSONLOG

template <class HB>
void Runner<HB>::calculate()
{
    HB::mc().sort();

#ifndef NOUT
    firstSave();
#endif // NOUT
#ifdef JSONLOG
    serializeStep(0);
#endif // JSONLOG

    ullong totalSteps = 0;
    double timeDelta = 0;
    double startTime = timestamp();

    while (!__terminate && _reactor->currentTime() <= _config->totalTime())
    {
        timeDelta = _reactor->doEvent();

#ifdef JSONLOG
        serializeStep(_reactor->currentTime());
#endif // JSONLOG

#if defined(PRINT) || defined(MC_PRINT)
        debugPrint([this, totalSteps](IndentStream &os) {
            os << "-----------------------------------------------\n"
               << totalSteps << ". " << _reactor->totalRate() << "\n";
        });
#endif // PRINT || MC_PRINT

        if (timeDelta < 0)
        {
            std::cout << "No more events" << std::endl;
            break;
        }

        ++totalSteps;
        if (totalSteps % MC_SORT_EACH_STEP == 0)
        {
            HB::mc().halfSort();
        }

#ifndef NOUT
        storeIfNeed(timeDelta, false);
#endif // NOUT
#ifdef ANY_PRINT
        DebugOutFlag::switchFlag((totalSteps % DEBUG_EACH_STEP) == 0);
#endif // ANY_PRINT
    }

    double stopTime = timestamp();
#ifdef ANY_PRINT
    DebugOutFlag::switchFlag(true);
#endif // ANY_PRINT

#ifndef NOUT
    storeIfNeed(timeDelta, true);
#endif // NOUT

#ifdef JSONLOG
    HB::stepsLogger().save();
#endif // JSONLOG

    _parallelWorker.stop();
    printStat(startTime, stopTime, totalSteps);
}

template <class HB>
void Runner<HB>::firstSave()
{
    processJob(_tracker->firstFrame(_reactor));
}

template <class HB>
void Runner<HB>::storeIfNeed(double timeDelta, bool forseSave)
{
    static uint stepsCounter = 0;

    _tracker->appendTime(timeDelta);

    if (stepsCounter == 0 || forseSave)
    {
        processJob(_tracker->nextFrame(_reactor));
    }

    if (++stepsCounter == TRACK_EACH_STEP)
    {
        stepsCounter = 0;
    }
}

template <class HB>
void Runner<HB>::processJob(Job *job)
{
    if (job->isEmpty())
    {
        delete job;
    }
    else
    {
        job->copyState();
        _parallelWorker.push(job);
    }
}

template <class HB>
double Runner<HB>::timestamp() const
{
    timeval tv;
    gettimeofday(&tv, 0);
    return tv.tv_sec + tv.tv_usec / 1e6;
}

template <class HB>
void Runner<HB>::outputMemoryUsage(std::ostream &os) const
{
    double vm, rss;
    process_mem_usage(vm, rss);
    os.precision(5);
    os << "Used virtual memory: " << (vm / 1024) << " MB\n"
       << "Used resident set: " << (rss / 1024) << " MB" << std::endl;
}

template <class HB>
void Runner<HB>::printStat(double startTime, double stopTime, ullong steps) const
{
    std::cout << std::endl;
    std::cout.precision(8);
    std::cout << "Elapsed time of process: " << _reactor->currentTime() << " s" << std::endl;
    std::cout << "Calculation time: " << (stopTime - startTime) << " s" << std::endl;

    std::cout << std::endl;
    outputMemoryUsage(std::cout);
    std::cout << std::endl;

    double percentOfRejection = 100 * (1 - (double)_reactor->evensCounter()->total() / steps);
    std::cout.precision(3);
    std::cout << "Rejected events rate: "
              << percentOfRejection << " %" << std::endl;

    _reactor->evensCounter()->printStats(std::cout);
}

}

#endif // RUNNER_H
