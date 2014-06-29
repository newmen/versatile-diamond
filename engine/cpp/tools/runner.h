#ifndef RUNNER_H
#define RUNNER_H

#include <iostream>
#include "../mc/common_mc_data.h"
#include "savers/crystal_slice_saver.h"
#include "savers/named_saver.h"
#include "tools/savers/mol_saver.h"
#include "common.h"
#include "error.h"

namespace vd
{

class Runner
{
    enum : ushort { MAX_HEIGHT = 100 };

    static volatile bool __stopCalculating;

    const std::string _name;
    const uint _x, _y;
    const double _totalTime, _eachTime;
    MolSaver *_volumeSaver = nullptr;

public:
    static void stop();

    Runner(const char *name, uint x, uint y, double totalTime, double eachTime, const char *volumeSaverType = nullptr);
    ~Runner();

    template <class SurfaceCrystalType, class Handbook>
    void calculate(const Detector *detector, const std::initializer_list<ushort> &types);

private:
    Runner(const Runner &) = delete;
    Runner(Runner &&) = delete;
    Runner &operator = (const Runner &) = delete;
    Runner &operator = (Runner &&) = delete;

    std::string filename() const;
    double timestamp() const;

    void outputMemoryUsage(std::ostream &os) const;
};

//////////////////////////////////////////////////////////////////////////////////////

template <class SCT, class HB>
void Runner::calculate(const Detector *detector, const std::initializer_list<ushort> &types)
{
    // TODO: Предоставить возможность сохранять концентрацию структур
    // TODO: Вынести отсюда эти циферки
    CrystalSliceSaver csSaver(filename().c_str(), _x * _y, types);

// -------------------------------------------------------------------------------- //

    SCT *surfaceCrystal = new SCT(dim3(_x, _y, MAX_HEIGHT));
    surfaceCrystal->initialize();

// -------------------------------------------------------------------------------- //

    auto outLambda = [this, surfaceCrystal]() {
        std::cout.width(10);
        std::cout << 100 * HB::mc().totalTime() / _totalTime << " %";
        std::cout.width(10);
        std::cout << surfaceCrystal->countAtoms();
        std::cout.width(10);
        std::cout << HB::amorph().countAtoms();
        std::cout.width(20);
        std::cout << HB::mc().totalTime() << " (s)";
        std::cout.width(20);
        std::cout << HB::mc().totalRate() << " (1/s)" << std::endl;
    };

    ullong steps = 0;
    double timeCounter = 0;
    uint volumeSaveCounter = 0;

    auto storeLambda = [this, surfaceCrystal, steps, &timeCounter, &volumeSaveCounter, &csSaver, detector](bool forseSaveVolume) {
        csSaver.writeBySlicesOf(surfaceCrystal, HB::mc().totalTime());

        if (_volumeSaver && (volumeSaveCounter == 0 || forseSaveVolume))
        {
            HB::amorph().setUnvisited();
            surfaceCrystal->setUnvisited();
            _volumeSaver->writeFrom(surfaceCrystal->firstAtom(), HB::mc().totalTime(), detector);
#ifndef NDEBUG
            HB::amorph().checkAllVisited();
            surfaceCrystal->checkAllVisited();
#endif // NDEBUG
        }

        if (++volumeSaveCounter == 10)
        {
            volumeSaveCounter = 0;
        }
    };

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

}

#endif // RUNNER_H
