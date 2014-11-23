#ifndef RUNNER_H
#define RUNNER_H

#include <iostream>
#include <sys/time.h>
#include "../mc/common_mc_data.h"
#include "../phases/behavior_factory.h"
#include "process_mem_usage.h"
#include "init_config.h"
#include "common.h"
#include "error.h"

#ifndef NEYRON
#include "savers/crystal_slice_saver.h"
#include "savers/volume_saver.h"
#include "savers/volume_saver_factory.h"
#include "savers/detector_factory.h"
#endif // NEYRON

namespace vd
{

template <class HB>
class Runner
{
    enum : ushort { MAX_HEIGHT = 100 };

    static volatile bool __stopCalculating;

    const std::string _name;
    const uint _x, _y;
    const double _totalTime;
#ifndef NEYRON
    const double _eachTime;
    const Detector *_detector = nullptr;
    VolumeSaver *_volumeSaver = nullptr;
#endif // NEYRON
    const Behavior *_behavior = nullptr;

public:
    static void stop();

    Runner(const InitConfig &init);
    ~Runner();

    void calculate(const std::initializer_list<ushort> &types);

private:
    Runner(const Runner &) = delete;
    Runner(Runner &&) = delete;
    Runner &operator = (const Runner &) = delete;
    Runner &operator = (Runner &&) = delete;

#ifndef NEYRON
    double activesRatio(const Crystal *crystal) const;
    void saveVolume(const Crystal *crystal);

    std::string filename() const;
#endif // NEYRON
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
Runner<HB>::Runner(const InitConfig &init) :
    _name(init.name), _x(init.x), _y(init.y),
#ifdef NEYRON
    _totalTime(init.totalTime)
#else
    _totalTime(init.totalTime), _eachTime(init.eachTime)
#endif // NEYRON
{
    if (_name.size() == 0)
    {
        throw Error("Name should not be empty");
    }
    else if (_x == 0 || _y == 0)
    {
        throw Error("X and Y sizes should be grater than 0");
    }
    else if (_totalTime <= 0)
    {
        throw Error("Total process time should be grater than 0 seconds");
    }
#ifndef NEYRON
    else if (_eachTime <= 0)
    {
        throw Error("Each time value should be grater than 0 seconds");
    }

    if (init.volumeSaverType)
    {
        VolumeSaverFactory vsFactory;
        if (!vsFactory.isRegistered(init.volumeSaverType))
        {
            throw Error("Undefined type of volume file saver");
        }

        _volumeSaver = vsFactory.create(init.volumeSaverType, filename().c_str());
    }

    DetectorFactory<HB> detFactory;
    if (init.detectorType)
    {
        if (!detFactory.isRegistered(init.detectorType))
        {
            throw Error("Undefined type of detector");
        }

        _detector = detFactory.create(init.detectorType);
    }
    else if (init.volumeSaverType)
    {
         _detector = detFactory.create("surf");
    }
#endif // NEYRON

    BehaviorFactory bhvrFactory;
    if (init.behavior)
    {
        if (!bhvrFactory.isRegistered(init.behavior))
        {
            throw Error("Undefined type of behavior");
        }

        _behavior = bhvrFactory.create(init.behavior);
    }
    else
    {
        _behavior = bhvrFactory.create("tor");
    }
}

template <class HB>
Runner<HB>::~Runner()
{
#ifndef NEYRON
    delete _volumeSaver;
    delete _detector;
#endif // NEYRON
}

#ifndef NEYRON
template <class HB>
std::string Runner<HB>::filename() const
{
    std::stringstream ss;
    ss << _name << "-" << _x << "x" << _y << "-" << _totalTime << "s";
    return ss.str();
}
#endif // NEYRON

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
    ullong steps = 0;

    const BehaviorFactory bhvrFactory;
    const Behavior *initBhv = bhvrFactory.create("tor");
    typedef typename HB::SurfaceCrystal SC;
    SC *surfaceCrystal = new SC(dim3(_x, _y, MAX_HEIGHT), initBhv);
    surfaceCrystal->initialize();
    surfaceCrystal->changeBehavior(_behavior);

    RandomGenerator::init(); // it must be called just one time at calculating begin (before init CommonMCData)

    CommonMCData mcData;
    HB::mc().initCounter(&mcData);

#ifndef NOUT
#ifndef NEYRON
    // TODO: Предоставить возможность сохранять концентрацию структур
    CrystalSliceSaver csSaver(filename().c_str(), _x * _y, types);

    auto outLambda = [this, surfaceCrystal]() {
        std::cout.width(10);
        std::cout << 100 * HB::mc().totalTime() / _totalTime << " %";
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

    double timeCounter = 0;
    uint volumeSaveCounter = 0;

    auto storeLambda = [this, surfaceCrystal, steps, &timeCounter, &volumeSaveCounter, &csSaver](bool forseSaveVolume) {
        csSaver.writeBySlicesOf(surfaceCrystal, HB::mc().totalTime());

        if (_volumeSaver)
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

    outLambda();
#endif // NEYRON
#endif // NOUT

    double startTime = timestamp();

    while (!__stopCalculating && HB::mc().totalTime() <= _totalTime)
    {
        double dt = HB::mc().doRandom(&mcData);

#ifdef PRINT
        debugPrint([&](std::ostream &os) {
            os << "-----------------------------------------------\n"
               << steps << ". " << HB::mc().totalRate() << "\n";
        });
#endif // PRINT

        ++steps;

#ifndef NOUT
#ifndef NEYRON
        timeCounter += dt;
        if (timeCounter >= _eachTime)
        {
            timeCounter = 0;
            outLambda();
            storeLambda(false);
        }
#endif // NEYRON
#endif // NOUT
    }

    double stopTime = timestamp();

#ifndef NOUT
#ifndef NEYRON
    if (timeCounter > 0)
    {
        outLambda();
        storeLambda(true);
    }
#endif // NEYRON
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

#ifndef NEYRON
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
    return (double)actives / hydrogens;
}

template <class HB>
void Runner<HB>::saveVolume(const Crystal *crystal)
{
    _volumeSaver->save(HB::mc().totalTime(), &HB::amorph(), crystal, _detector);
}
#endif // NEYRON

}

#endif // RUNNER_H
