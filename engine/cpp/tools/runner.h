#ifndef RUNNER_H
#define RUNNER_H

#include <iostream>
#include <sys/time.h>
#include "../mc/common_mc_data.h"
#include "process_mem_usage.h"
#include "../phases/behavior_factory.h"
#include "savers/crystal_slice_saver.h"
#include "init_config.h"
#include "common.h"

namespace vd
{

template <class HB>
class Runner
{
    enum : ushort { MAX_HEIGHT = 100 };

    static volatile bool __stopCalculating;

    const InitConfig _init;

public:
    static void stop();

    Runner(const InitConfig &init) : _init(init) {}

    void calculate(const std::initializer_list<ushort> &types);

private:
    Runner(const Runner &) = delete;
    Runner(Runner &&) = delete;
    Runner &operator = (const Runner &) = delete;
    Runner &operator = (Runner &&) = delete;

    double activesRatio(const Crystal *crystal) const;
    void saveVolume(const Crystal *crystal);

    std::string filename() const;
    double timestamp() const;

    void outputMemoryUsage(std::ostream &os) const;
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
    CrystalSliceSaver csSaver(_init.filename().c_str(), _init.x * _init.y, types);

// -------------------------------------------------------------------------------- //

    const BehaviorFactory bhvrFactory;
    const Behavior *initBhv = bhvrFactory.create("tor");
    typedef typename HB::SurfaceCrystal SC;
    SC *surfaceCrystal = new SC(dim3(_init.x, _init.y, MAX_HEIGHT), initBhv);
    surfaceCrystal->initialize();
    surfaceCrystal->changeBehavior(_init.behavior);

// -------------------------------------------------------------------------------- //

    auto outLambda = [this, surfaceCrystal]() {
        std::cout.width(10);
        std::cout << 100 * HB::mc().totalTime() / _init.totalTime << " %";
        std::cout.width(10);
        std::cout << surfaceCrystal->countAtoms();
        std::cout.width(10);
        std::cout << HB::amorph().countAtoms();
        std::cout.width(10);
        std::cout << 100 * activesRatio(surfaceCrystal) << " %";
        std::cout.width(20);
        std::cout << HB::mc().totalTime() << " (s)";
        std::cout.width(20);
        std::cout << HB::mc().totalRate() << " (1/s)" << std::endl;
    };

    ullong steps = 0;
    double timeCounter = 0;
    uint volumeSaveCounter = 0;

    auto storeLambda = [this, surfaceCrystal, steps, &timeCounter, &volumeSaveCounter, &csSaver](bool forseSaveVolume) {
        csSaver.writeBySlicesOf(surfaceCrystal, HB::mc().totalTime());

        if (_init.volumeSaver)
        {
            if (volumeSaveCounter == 0 || forseSaveVolume)
            {
                saveVolume(surfaceCrystal);
            }
            if (++volumeSaveCounter == 10)
            {
                volumeSaveCounter = 0;
            }
        }
    };

    RandomGenerator::init(); // it must be called just one time at calculating begin (before init CommonMCData)

    CommonMCData mcData;
    HB::mc().initCounter(&mcData);

#ifndef NOUT
    outLambda();
#endif // NOUT

    double startTime = timestamp();

#ifdef PARALLEL
#pragma omp parallel
#endif // PARALLEL
    while (!__stopCalculating && HB::mc().totalTime() <= _init.totalTime)
    {
        double dt = HB::mc().doRandom(&mcData);

#ifdef PRINT
        debugPrint([&](std::ostream &os) {
            os << "-----------------------------------------------\n"
               << steps << ". " << HB::mc().totalRate() << "\n";
        });
#endif // PRINT

#ifdef PARALLEL
#pragma omp atomic
#endif // PARALLEL
        ++steps;

#ifndef NOUT
#ifdef PARALLEL
#pragma omp critical
#endif // PARALLEL
        {
            timeCounter += dt;
            if (timeCounter >= _init.eachTime)
            {
                timeCounter = 0;
                outLambda();
                storeLambda(false);
            }
        }
#endif // NOUT
    }

    double stopTime = timestamp();

#ifndef NOUT
    if (timeCounter > 0)
    {
        outLambda();
        storeLambda(true);
    }
#endif // NOUT

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

    HB::amorph().clear(); // TODO: should not be explicitly!
    delete surfaceCrystal;
}

template <class HB>
double Runner<HB>::activesRatio(const Crystal *crystal) const
{
    uint actives = 0;
    uint hydrogens = 0;
    auto lambda = [&actives, &hydrogens](const Atom *atom) {
        actives += HB::activesFor(atom);
        hydrogens += HB::hydrogensFor(atom);
    };

    HB::amorph().eachAtom(lambda);
    crystal->eachAtom(lambda);
    return (double)actives / (actives + hydrogens);
}

template <class HB>
void Runner<HB>::saveVolume(const Crystal *crystal)
{
    _init.volumeSaver->save(HB::mc().totalTime(), &HB::amorph(), crystal, _init.detector);
}

}

#endif // RUNNER_H
