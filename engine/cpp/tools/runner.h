#ifndef RUNNER_H
#define RUNNER_H

#include <iostream>
#include "../mc/common_mc_data.h"
#include "savers/crystal_slice_saver.h"
#include "savers/mol_saver.h"
#include "common.h"
#include "error.h"

#include "../generations/handbook.h"

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

    template <class SurfaceCrystalType> void calculate();

private:
    Runner(const Runner &) = delete;
    Runner(Runner &&) = delete;
    Runner &operator = (const Runner &) = delete;
    Runner &operator = (Runner &&) = delete;

    std::string filename() const;
    double timestamp() const;

    void outputMemoryUsage(std::ostream &os) const;
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class SCT>
void Runner::calculate()
{
    CrystalSliceSaver csSaver(filename().c_str(), _x * _y, { 0, 2, 4, 5, 20, 21, 24, 28, 32 });

// ------------------------------------------------------------------------------------------------------------------ //

    SCT *surfaceCrystal = new SCT(dim3(_x, _y, MAX_HEIGHT));
    surfaceCrystal->initialize();

// ------------------------------------------------------------------------------------------------------------------ //

    std::cout << "Begin crystal atoms num: " << surfaceCrystal->countAtoms() << "\n" << std::endl;

    ullong steps = 0;
    double timeCounter = 0;
    uint volumeSaveCounter = 0;

    auto outLambda = [this, surfaceCrystal, steps, &timeCounter, &volumeSaveCounter, &csSaver](bool forseSaveVolume) {
        double currentTime = Handbook::mc().totalTime();

        std::cout.width(10);
        std::cout << 100 * currentTime / _totalTime << " %";
        std::cout.width(10);
        std::cout << surfaceCrystal->countAtoms();
        std::cout.width(10);
        std::cout << Handbook::amorph().countAtoms();
        std::cout.width(20);
        std::cout << currentTime << " (s)";
        std::cout.width(20);
        std::cout << Handbook::mc().totalRate() << " (1/s)" << std::endl;

        // ----------------------------------------------------------- //

        csSaver.writeBySlicesOf(surfaceCrystal, currentTime);

        // ----------------------------------------------------------- //

        if (_volumeSaver && (volumeSaveCounter == 0 || forseSaveVolume))
        {
            Handbook::amorph().setUnvisited();
            surfaceCrystal->setUnvisited();
            _volumeSaver->writeFrom(surfaceCrystal->firstAtom(), currentTime);
#ifndef NDEBUG
            Handbook::amorph().checkAllVisited();
            surfaceCrystal->checkAllVisited();
#endif // NDEBUG
        }

        if (++volumeSaveCounter == 10)
        {
            volumeSaveCounter = 0;
        }
    };

    CommonMCData mcData;
    Handbook::mc().initCounter(&mcData);

    double startTime = timestamp();

#ifdef PARALLEL
#pragma omp parallel
#endif // PARALLEL
    while (!__stopCalculating && Handbook::mc().totalTime() <= _totalTime)
    {
        double dt = Handbook::mc().doRandom(&mcData);

#ifdef PRINT
        debugPrint([&](std::ostream &os) {
            os << "-----------------------------------------------\n"
               << steps << ". " << Handbook::mc().totalRate() << "\n";
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
                outLambda(false);
            }
        }
#endif // NOUT
    }

    if (timeCounter > 0)
    {
        outLambda(true);
    }

    double stopTime = timestamp();

    std::cout << "\nEnd crystal atoms num: " << surfaceCrystal->countAtoms() << "\n" << std::endl;
    std::cout.precision(5);
    std::cout << "Elapsed time of process: " << Handbook::mc().totalTime() << " s" << std::endl;
    std::cout << "Calculation time: " << (stopTime - startTime) << " s" << std::endl;

    std::cout << std::endl;
    outputMemoryUsage(std::cout);
    std::cout << std::endl;

    std::cout.precision(3);
    std::cout << "Rejected events rate: " << 100 * (1 - (double)mcData.counter()->total() / steps) << " %" << std::endl;
    mcData.counter()->printStats(std::cout);

    Handbook::amorph().clear(); // TODO: should not be explicitly!
    delete surfaceCrystal;
}

}

#endif // RUNNER_H
