#ifndef RUNNER_H
#define RUNNER_H

#include <iostream>
#include <sys/time.h>
#include "../mc/common_mc_data.h"
#include "../hand-generations/src/handbook.h"
#include "../phases/behavior_factory.h"
#include "../phases/saving_amorph.h"
#include "../phases/saving_crystal.h"
#include "process_mem_usage.h"
#include "init_config.h"
#include "common.h"

namespace vd
{

template <class HB>
class Runner
{
    enum : ushort { MAX_HEIGHT = 100 };

    static volatile bool __stopCalculating;

    const InitConfig<Handbook> _init;

public:
    static void stop();

    Runner(const InitConfig<Handbook> &init) : _init(init) {}
    ~Runner();

    void calculate(const std::initializer_list<ushort> &types);

private:
    Runner(const Runner &) = delete;
    Runner(Runner &&) = delete;
    Runner &operator = (const Runner &) = delete;
    Runner &operator = (Runner &&) = delete;

    QueueItem *createBuilders(const std::initializer_list<ushort> &types, const Amorph *amorph, const Crystal *crystal);

    // ЭТИ ДВА МЕТОДА УХОДЯТ В ПРОГРЕСС САВЕР
    double activesRatio(const SavingCrystal *crystal, const SavingAmorph *amorph) const;
    void printShortState(const SavingCrystal *crystal, const SavingAmorph *amorph);


    void storeIfNeed(const Crystal *crystal,
                     const Amorph *amorph,
                     double totalTime,
                     double dt,
                     bool forseSave);

    std::string filename() const;
    double timestamp() const;

    typename HB::SurfaceCrystal *initCrystal();

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
    typename HB::SurfaceCrystal *surfaceCrystal = initCrystal();

    RandomGenerator::init(); // it must be called just one time at calculating begin (before init CommonMCData)

    CommonMCData mcData;
    HB::mc().initCounter(&mcData);

#ifndef NOUT
    // СОЗДАЁМ ПРОГРЕСС СЕЙВЕР И ДУШУ, ОБОРАЧИВАЕМ СЕЙВЕРОМ ДУШУ,
    // ЗОВЁМ COPYDATA && SAVEDATA
    // УБИВАЕМ ТО ЧТО СОЗДАЛИ
    // ВСЁ ЭТО В ОТДЕЛЬНОМ МЕТОДЕ, И ТУТ ПРОСТО ВЫЗОВ ЭТОГО МЕТОДА

    SavingPhases savingPhases = copyAtoms(surfaceCrystal, &HB::amorph());
    printShortState(std::get<0>(savingPhases), std::get<1>(savingPhases));
    delete std::get<0>(savingPhases);
    delete std::get<1>(savingPhases);
#endif // NOUT

    ullong steps = 0;
    double dt = 0;
    double startTime = timestamp();

    while (!__stopCalculating && HB::mc().totalTime() <= _init.totalTime)
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
            storeIfNeed(surfaceCrystal, &HB::amorph(), HB::mc().totalTime(), dt, false);
        }
#endif // NOUT
    }

    double stopTime = timestamp();

#ifndef NOUT
    storeIfNeed(surfaceCrystal, &HB::amorph(), HB::mc().totalTime(), dt, true);
#endif // NOUT

    printStat(startTime, stopTime, mcData, steps);
    HB::amorph().clear(); // TODO: should not be explicitly!
    delete surfaceCrystal;
}

template <class HB>
QueueItem *Runner<HB>::createBuilders(const std::initializer_list<ushort> &types, const Amorph *amorph, const Crystal *crystal)
{
    DetectorFactory<HB> detFactory;
    Treker* treker = new Treker();

    if (_init.yamlReader->isDefined("integral", "step"))
    {
        treker->addItem(new IntegralSaverBuilder(
                            _init.name.c_str(),
                            _init.x * _init.y,
                            types,
                            _init.yamlReader->read<double>("integral", "step")));
    }

    if (_init.yamlReader->isDefined("dump", "step"))
    {
        treker->addItem(new DumpSaverBuilder(
                            _init.x,
                            _init.y,
                            detFactory.create(_init.yamlReader->read<std::string>("dump", "detector")),
                            _init.yamlReader->read<double>("dump", "step")));
    }

    if (_init.yamlReader->isDefined("mol", "step"))
    {
        treker->addItem(new VolumeSaversBuilder(
                            detFactory.create(_init.yamlReader->read<std::string>("mol", "detector")),
                            "mol",
                            _init.name.c_str(),
                            _init.yamlReader->read<double>("mol", "step")));
    }

    if (_init.yamlReader->isDefined("sdf", "step"))
    {
        treker->addItem(new VolumeSaversBuilder(
                            detFactory.create(_init.yamlReader->read<std::string>("sdf", "detector")),
                            "sdf",
                            _init.name.c_str(),
                            _init.yamlReader->read<double>("sdf", "step")));
    }

    if (_init.yamlReader->isDefined("xyz", "step"))
    {
        treker->addItem(new VolumeSaversBuilder(
                            detFactory.create(_init.yamlReader->read<std::string>("xyz", "detector")),
                            "xyz",
                            _init.name.c_str(),
                            _init.yamlReader->read<double>("xyz", "step")));
    }

    return treker->takeItem(new Soul(amorph, crystal));
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
typename HB::SurfaceCrystal *Runner<HB>::initCrystal()
{
    const BehaviorFactory bhvrFactory;
    const Behavior *initBhv = bhvrFactory.create("tor");
    typedef typename HB::SurfaceCrystal SC;
    SC *surfaceCrystal = new SC(dim3(_init.x, _init.y, MAX_HEIGHT), initBhv);
    surfaceCrystal->initialize();
    surfaceCrystal->changeBehavior(_init.behavior);
    return surfaceCrystal;
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
void Runner<HB>::storeIfNeed(const Crystal *crystal,
                             const Amorph *amorph,
                             double totalTime,
                             double dt,
                             bool forseSave)
{
    static uint volumeSaveCounter = 0;

    sliceSaver->writeBySlicesOf(crystal, HB::mc().totalTime());

    if (volumeSaveCounter == 0 || forseSave)
    {
        // ЮЗАЯ ТРЕКЕР СОЗДАЁМ КУИТЕМ
        // ПРОВЕРЯЕМ ПУСТ ЛИ ОН
        // ЕСЛИ НЕ ПУСТ, ТО КОПИРУЕМ
        // В ТРЕДЕ ЗАПУСКАЕМ СОХРАНЕНИЕ И УДАЛЕНИЕ
        // ВСЁ ЭТО В ОТДЕЛЬНОМ МЕТОДЕ И ТУТ ВЫЗОВ ЭТОГО МЕТОДА
    }
    if (++volumeSaveCounter == 10)
    {
        volumeSaveCounter = 0;
    }
}

}

#endif // RUNNER_H
