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

    double timeCounter = 0;
    ullong steps = 0;
    CommonMCData mcData;
    Handbook::mc().initCounter(&mcData);

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

                // ----------------------------------------------------------- //

                std::cout.width(10);
                std::cout << 100 * Handbook::mc().totalTime() / _totalTime << " %";
                std::cout.width(10);
                std::cout << surfaceCrystal->countAtoms();
                std::cout.width(10);
                std::cout << Handbook::amorph().countAtoms();
                std::cout.width(20);
                std::cout << Handbook::mc().totalTime() << " (s)";
                std::cout.width(20);
                std::cout << Handbook::mc().totalRate() << " (1/s)" << std::endl;

                // ----------------------------------------------------------- //

                csSaver.writeBySlicesOf(surfaceCrystal, Handbook::mc().totalTime());

                // ----------------------------------------------------------- //

                if (_volumeSaver)
                {
                    Handbook::amorph().setUnvisited();
                    surfaceCrystal->setUnvisited();
                    _volumeSaver->writeFrom(surfaceCrystal->firstAtom());
#ifndef NDEBUG
                    Handbook::amorph().checkAllVisited();
                    surfaceCrystal->checkAllVisited();
#endif // NDEBUG
                }
            }
        }
#endif // NOUT
    }

    std::cout << "\nEnd crystal atoms num: " << surfaceCrystal->countAtoms() << "\n"
              << "Rejected events rate: " << 100 * (1 - (double)mcData.counter()->total() / steps) << " %\n"
              << std::endl;
    std::cout << "Elapsed time of process: " << Handbook::mc().totalTime() << " s" << std::endl;
    mcData.counter()->printStats();

    Handbook::amorph().clear(); // TODO: should not be explicitly!
    delete surfaceCrystal;
}

}

#endif // RUNNER_H