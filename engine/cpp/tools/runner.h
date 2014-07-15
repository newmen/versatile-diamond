#ifndef RUNNER_H
#define RUNNER_H

#include <iostream>
#include <sys/time.h>
#include "../mc/common_mc_data.h"
#include "process_mem_usage.h"
#include "savers/actives_portion_counter.h"
#include "savers/crystal_slice_saver.h"
#include "savers/volume_saver.h"
#include "savers/volume_saver_factory.h"
#include "savers/detector_factory.h"
#include "common.h"
#include "error.h"

namespace vd
{

template <class HB>
class Runner
{
    enum : ushort { MAX_HEIGHT = 100 };

    static volatile bool __stopCalculating;

    const std::string _name;
    const uint _x, _y;
    const double _totalTime, _eachTime;
    const ActivesPortionCounter<HB> *_apCounter;
    const Detector *_detector = nullptr;
    VolumeSaver *_volumeSaver = nullptr;

public:
    static void stop();

    Runner(const char *name, uint x, uint y, double totalTime, double eachTime, const char *volumeSaverType = nullptr, const char *detector = nullptr);
    ~Runner();

    void calculate(const std::initializer_list<ushort> &types);

private:
    Runner(const Runner &) = delete;
    Runner(Runner &&) = delete;
    Runner &operator = (const Runner &) = delete;
    Runner &operator = (Runner &&) = delete;

    template <class Lambda>
    void visitAtoms(Crystal *crystal, const Lambda &lambda) const;

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
Runner<HB>::Runner(const char *name, uint x, uint y, double totalTime, double eachTime, const char *volumeSaverType, const char *detector) :
    _name(name), _x(x), _y(y), _totalTime(totalTime), _eachTime(eachTime)
{
    if (_name.size() == 0)
    {
        throw Error("Name should not be empty");
    }
    else if (x == 0 || y == 0)
    {
        throw Error("X and Y sizes should be grater than 0");
    }
    else if (_totalTime <= 0)
    {
        throw Error("Total process time should be grater than 0 seconds");
    }
    else if (_eachTime <= 0)
    {
        throw Error("Each time value should be grater than 0 seconds");
    }

    if (volumeSaverType)
    {
        VolumeSaverFactory vsFactory;
        if (!vsFactory.isRegistered(volumeSaverType))
        {
            throw Error("Undefined type of volume file saver");
        }

        _volumeSaver = vsFactory.create(volumeSaverType, filename().c_str());

        if (!detector)
            detector = "surf";
    }

    if (detector)
    {
        DetectorFactory<HB> detFactory;
        if (!detFactory.isRegistered(detector))
        {
            throw Error("Undefined type of detector");
        }

        _detector = detFactory.create(detector);
    }
}

template <class HB>
Runner<HB>::~Runner()
{
    delete _volumeSaver;
    delete _detector;
}

template <class HB>
std::string Runner<HB>::filename() const
{
    std::stringstream ss;
    ss << _name << "-" << _x << "x" << _y << "-" << _totalTime << "s";
    return ss.str();
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
    CrystalSliceSaver csSaver(filename().c_str(), _x * _y, types);

// -------------------------------------------------------------------------------- //

    typedef typename HB::SurfaceCrystal SC;
    SC *surfaceCrystal = new SC(dim3(_x, _y, MAX_HEIGHT));
    surfaceCrystal->initialize();

// -------------------------------------------------------------------------------- //

    auto outLambda = [this, surfaceCrystal]() {
        double activesRatio = 0;
        visitAtoms(surfaceCrystal, [this, &activesRatio](Atom *firstAtom) {
            activesRatio = _apCounter->countFrom(firstAtom);
        });

        std::cout.width(10);
        std::cout << 100 * HB::mc().totalTime() / _totalTime << " %";
        std::cout.width(10);
        std::cout << surfaceCrystal->countAtoms();
        std::cout.width(10);
        std::cout << HB::amorph().countAtoms();
        std::cout.width(10);
        std::cout << 100 * activesRatio << " %";
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

        if (_volumeSaver && (volumeSaveCounter == 0 || forseSaveVolume))
        {
            visitAtoms(surfaceCrystal, [this](Atom *firstAtom) {
                _volumeSaver->writeFrom(firstAtom, HB::mc().totalTime(), _detector);
            });
        }

        if (++volumeSaveCounter == 10)
        {
            volumeSaveCounter = 0;
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
    while (!__stopCalculating && HB::mc().totalTime() <= _totalTime)
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
            if (timeCounter >= _eachTime)
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
template <class L>
void Runner<HB>::visitAtoms(Crystal *crystal, const L &lambda) const
{
    HB::amorph().setUnvisited();
    crystal->setUnvisited();

    lambda(crystal->firstAtom());

#ifndef NDEBUG
    HB::amorph().checkAllVisited();
    crystal->checkAllVisited();
#endif // NDEBUG
}

}

#endif // RUNNER_H
