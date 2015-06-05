#ifndef RUNNER_H
#define RUNNER_H

#include <iostream>
#include <sys/time.h>
#include "../mc/common_mc_data.h"
#include "../hand-generations/src/handbook.h"
#include "../phases/behavior_factory.h"
#include "../phases/saving_amorph.h"
#include "../phases/saving_crystal.h"
#include "../savers/progress_saver_counter.h"
#include "../savers/queue/out_thread.h"
#include "process_mem_usage.h"
#include "init_config.h"
#include "common.h"

namespace vd
{

template <class HB>
class Runner
{
    static volatile bool __stopCalculating;

    InitConfig<Handbook> _init;
    OutThread _savingQueue;

public:
    static void stop();

    Runner(const InitConfig<Handbook> &init) : _init(init) {}
    ~Runner() {}

    void calculate(const std::initializer_list<ushort> &types);

private:
    Runner(const Runner &) = delete;
    Runner(Runner &&) = delete;
    Runner &operator = (const Runner &) = delete;
    Runner &operator = (Runner &&) = delete;

    void storeIfNeed(const Crystal *crystal,
                     const Amorph *amorph,
                     double dt,
                     bool forseSave);

    std::string filename() const;
    double timestamp() const;

    void firstSave(const Amorph *amorph, const Crystal *crystal, const char *name);

    void outputMemoryUsage(std::ostream &os) const;
    void printStat(double startTime, double stopTime, CommonMCData &mcData, ullong steps) const;
};

//////////////////////////////////////////////////////////////////////////////////////

template <class HB>
volatile bool Runner<HB>::__stopCalculating = false;

template <class HB>
void Runner<HB>::stop()
{
    __stopCalculating = true;
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
void Runner<HB>::calculate(const std::initializer_list<ushort> &types)
{
    // TODO: Предоставить возможность сохранять концентрацию структур
    typename HB::SurfaceCrystal *surfaceCrystal = _init.initCrystal();

    RandomGenerator::init(); // it must be called just one time at calculating begin (before init CommonMCData)

    CommonMCData mcData;
    HB::mc().initCounter(&mcData);

    _init.initTraker(types);

#ifndef NOUT
    firstSave(&HB::amorph(), surfaceCrystal, _init.name());
#endif // NOUT

    ullong steps = 0;
    double dt = 0;
    double startTime = timestamp();

    while (!__stopCalculating && HB::mc().totalTime() <= _init.totalTime())
    {
        dt = HB::mc().doRandom(&mcData);

#ifdef PRINT
        debugPrint([&](std::ostream &os) {
            os << "-----------------------------------------------\n"
               << steps << ". " << HB::mc().totalRate() << "\n";
        });
#endif // PRINT

        ++steps;

#ifndef NOUT
        if (dt < 0)
        {
            std::cout << "No more events" << std::endl;
            break;
        }
        else
        {
            storeIfNeed(surfaceCrystal, &HB::amorph(), dt, false);
        }
#endif // NOUT
    }

    double stopTime = timestamp();

#ifndef NOUT
    storeIfNeed(surfaceCrystal, &HB::amorph(), dt, true);
#endif // NOUT

    _savingQueue.stop();
    printStat(startTime, stopTime, mcData, steps);
    HB::amorph().clear(); // TODO: should not be explicitly!
    delete surfaceCrystal;
}

template <class HB>
void Runner<HB>::printStat(double startTime, double stopTime, CommonMCData &mcData, ullong steps) const
{
    std::cout << std::endl;
    std::cout.precision(8);
    std::cout << "Elapsed time of process: " << HB::mc().totalTime() << " s" << std::endl;
    std::cout << "Calculation time: " << (stopTime - startTime) << " s" << std::endl;

    std::cout << std::endl;
    outputMemoryUsage(std::cout);
    std::cout << std::endl;

    std::cout.precision(3);
    std::cout << "Rejected events rate: " << 100 * (1 - (double)mcData.counter()->total() / steps) << " %" << std::endl;
    mcData.counter()->printStats(std::cout);
}

template <class HB>
void Runner<HB>::firstSave(const Amorph *amorph, const Crystal *crystal, const char *name)
{
    QueueItem *item = new Soul(amorph, crystal);
    ProgressSaver<HB> *saver = new ProgressSaver<HB>();
    static ProgressSaverCounter<HB> progress(0, saver);
    item = progress.wrapItem(item);
    _savingQueue.push(item, _init.totalTime(), 0, name);
}

template <class HB>
void Runner<HB>::storeIfNeed(const Crystal *crystal, const Amorph *amorph, double dt, bool forseSave)
{
    static uint takeCounter = 0;
    static double currentTime = 0;

    currentTime += dt;
    _init.appendTime(dt);

    if (takeCounter == 0 || forseSave)
    {
        QueueItem *item = _init.takeItem(amorph, crystal);

        if (!item->isEmpty())
        {
            _savingQueue.push(item, _init.totalTime(), currentTime, _init.name());
        }
        else
        {
            delete item;
        }
    }
    if (++takeCounter == 10)
    {
        takeCounter = 0;
    }
}

}

#endif // RUNNER_H
