#ifndef RUNNER_H
#define RUNNER_H

#include <tuple>
#include <unordered_map>
#include <iostream>
#include <sys/time.h>
#include "../mc/common_mc_data.h"
#include "../phases/behavior_factory.h"
#include "../phases/saving_amorph.h"
#include "../phases/saving_crystal.h"
#include "process_mem_usage.h"
#include "savers/crystal_slice_saver.h"
#include "savers/volume_saver.h"
#include "savers/volume_saver_factory.h"
#include "savers/detector_factory.h"
#include "init_config.h"
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
    const Detector *_detector = nullptr;
    const Behavior *_behavior = nullptr;
    VolumeSaver *_volumeSaver = nullptr;

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

    typedef std::tuple<const SavingCrystal *, const SavingAmorph *> SavingPhases;
    SavingPhases copyAtoms(const Crystal *crystal, const Amorph *amorph) const;

    double activesRatio(const SavingCrystal *crystal, const SavingAmorph *amorph) const;
    void printShortState(const SavingCrystal *crystal, const SavingAmorph *amorph);
    void saveVolume(const SavingCrystal *crystal, const SavingAmorph *amorph);
    void storeIfNeed(CrystalSliceSaver *sliceSaver,
                     const SavingCrystal *crystal,
                     const SavingAmorph *amorph,
                     bool forseSaveVolume);

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
Runner<HB>::Runner(const InitConfig &init) :
    _name(init.name), _x(init.x), _y(init.y), _totalTime(init.totalTime), _eachTime(init.eachTime)
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

    const BehaviorFactory bhvrFactory;
    const Behavior *initBhv = bhvrFactory.create("tor");
    typedef typename HB::SurfaceCrystal SC;
    SC *surfaceCrystal = new SC(dim3(_x, _y, MAX_HEIGHT), initBhv);
    surfaceCrystal->initialize();
    surfaceCrystal->changeBehavior(_behavior);

// -------------------------------------------------------------------------------- //

    ullong steps = 0;
    double timeCounter = 0;

    RandomGenerator::init(); // it must be called just one time at calculating begin (before init CommonMCData)

    CommonMCData mcData;
    HB::mc().initCounter(&mcData);

#ifndef NOUT
    SavingPhases savingPhases = copyAtoms(surfaceCrystal, &HB::amorph());
    printShortState(std::get<0>(savingPhases), std::get<1>(savingPhases));
    delete std::get<0>(savingPhases);
    delete std::get<1>(savingPhases);
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
        if (dt < 0)
        {
            std::cout << "No more events" << std::endl;
            break;
        }
        else
        {
            timeCounter += dt;
            if (timeCounter >= _eachTime)
            {
                timeCounter = 0;
                SavingPhases savingPhases = copyAtoms(surfaceCrystal, &HB::amorph());
                printShortState(std::get<0>(savingPhases), std::get<1>(savingPhases));
                storeIfNeed(&csSaver, std::get<0>(savingPhases), std::get<1>(savingPhases), false);
                delete std::get<0>(savingPhases);
                delete std::get<1>(savingPhases);
            }
        }
#endif // NOUT
    }

    double stopTime = timestamp();

#ifndef NOUT
    if (timeCounter > 0)
    {
        SavingPhases savingPhases = copyAtoms(surfaceCrystal, &HB::amorph());
        printShortState(std::get<0>(savingPhases), std::get<1>(savingPhases));
        storeIfNeed(&csSaver, std::get<0>(savingPhases), std::get<1>(savingPhases), true);
        delete std::get<0>(savingPhases);
        delete std::get<1>(savingPhases);
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
typename Runner<HB>::SavingPhases Runner<HB>::copyAtoms(const Crystal *crystal, const Amorph *amorph) const
{
    std::unordered_map<const Atom *, SavingAtom *> mirror;
    mirror.reserve(crystal->maxAtoms() + amorph->countAtoms());

    SavingCrystal *savingCrystal = new SavingCrystal(crystal);
    SavingAmorph *savingAmorph = new SavingAmorph();

    auto fillLambda = [&mirror, savingCrystal, savingAmorph](const Atom *atom) {
        SavingAtom *sa = new SavingAtom(atom, nullptr);
        mirror[atom] = sa;

        auto originalLattice = atom->lattice();
        if (originalLattice) {
            savingCrystal->insert(sa, originalLattice->coords());
        } else {
            savingAmorph->insert(sa);
        }
    };

    crystal->eachAtom(fillLambda);
    amorph->eachAtom(fillLambda);

    auto copyRelationsLambda = [&mirror](const Atom *atom) {
        SavingAtom *target = mirror.find(atom)->second;
        atom->eachNeighbour([&mirror, target](const Atom *nbr) {
            target->bondWith(mirror.find(nbr)->second, 0);
        });
    };

    crystal->eachAtom(copyRelationsLambda);
    amorph->eachAtom(copyRelationsLambda);

    return std::make_tuple(savingCrystal, savingAmorph);
}

template <class HB>
double Runner<HB>::activesRatio(const SavingCrystal *crystal, const SavingAmorph *amorph) const
{
    uint actives = 0;
    uint hydrogens = 0;
    auto lambda = [&actives, &hydrogens](const SavingAtom *atom) {
        actives += HB::activesFor(atom->type());
        hydrogens += HB::hydrogensFor(atom->type());
    };

    amorph->eachAtom(lambda);
    crystal->eachAtom(lambda);
    return (double)actives / (actives + hydrogens);
}

template <class HB>
void Runner<HB>::printShortState(const SavingCrystal *crystal, const SavingAmorph *amorph)
{
    std::cout.width(10);
    std::cout << 100 * HB::mc().totalTime() / _totalTime << " %";
    std::cout.width(10);
    std::cout << crystal->countAtoms();
    std::cout.width(10);
    std::cout << amorph->countAtoms();
    std::cout.width(10);
    std::cout << 100 * activesRatio(crystal, amorph) << " %";
    std::cout.width(20);
    std::cout << HB::mc().totalTime() << " (s)";
    std::cout.width(20);
    std::cout << HB::mc().totalRate() << " (1/s)" << std::endl;
}

template <class HB>
void Runner<HB>::saveVolume(const SavingCrystal *crystal, const SavingAmorph *amorph)
{
    _volumeSaver->save(HB::mc().totalTime(), amorph, crystal, _detector);
}

template <class HB>
void Runner<HB>::storeIfNeed(CrystalSliceSaver *sliceSaver,
                             const SavingCrystal *crystal,
                             const SavingAmorph *amorph,
                             bool forseSaveVolume)
{
    static uint volumeSaveCounter = 0;

    sliceSaver->writeBySlicesOf(crystal, HB::mc().totalTime());

    if (_volumeSaver)
    {
        if (volumeSaveCounter == 0 || forseSaveVolume)
        {
            saveVolume(crystal, amorph);
        }
        if (++volumeSaveCounter == 10)
        {
            volumeSaveCounter = 0;
        }
    }
}

}

#endif // RUNNER_H
