#include <signal.h>
#include <omp.h>
#include <tools/init_config.h>
#include "run.h"

#ifdef NEYRON
#include <init.h>
#endif // NEYRON

void stopSignalHandler(int)
{
    Runner<Handbook>::stop();
}

int main(int argc, char *argv[])
{
    std::cout.precision(3);

    if (argc < 6 || argc > 9)
    {
        std::cerr << "Wrong number of run arguments!" << std::endl;
        std::cout << "Try: " << argv[0] << " run_name X Y total_time save_each_time [out_format] [detector_type] [behaviour_type]" << std::endl;
        return 1;
    }

    signal(SIGINT, stopSignalHandler);
    signal(SIGTERM, stopSignalHandler);

#ifdef NEYRON
    std::vector<Localizator *> localizators = createLocalizators();
#endif // NEYRON

    try
    {
        const InitConfig init(argc, argv);
        Runner<Handbook> runner(init);
        run(runner);
    }
    catch (Error error)
    {
        std::cerr << "Run error:\n  " << error.message() << std::endl;
    }

#ifdef NEYRON
    for (Localizator *localizator : localizators)
    {
        delete localizator;
    }
#endif // NEYRON

    return 0;
}
