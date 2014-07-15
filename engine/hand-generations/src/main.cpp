#include <signal.h>
#include <omp.h>
#include "run.h"

void stopSignalHandler(int)
{
#ifdef PARALLEL
#pragma omp master
#endif // PARALLEL
    Runner<Handbook>::stop();
}

void segfaultSignalHandler(int)
{
    std::cerr << "Segmentation fault signal recived! Stop computing..." << std::endl;
    exit(1);
}

int main(int argc, char *argv[])
{
    std::cout.precision(3);

    if (argc < 6 || argc > 8)
    {
        std::cerr << "Wrong number of run arguments!" << std::endl;
        std::cout << "Try: " << argv[0] << " run_name X Y total_time save_each_time [out_format]" << std::endl;
        return 1;
    }

    signal(SIGINT, stopSignalHandler);
    signal(SIGTERM, stopSignalHandler);
#ifndef PARALLEL
    signal(SIGSEGV, segfaultSignalHandler);
#endif // PARALLEL

#ifdef PARALLEL
    omp_set_num_threads(THREADS_NUM);
#endif // PARALLEL

#ifdef PRINT
    debugPrint([&](std::ostream &os) {
#ifdef PARALLEL
        os << "Start as PARALLEL mode";
#else
        os << "Start as SINGLE THREAD mode";
#endif // PARALLEL
    });
#endif // PRINT

    try
    {
        const char *volumeSaverType = (argc == 7 || argc == 8) ? argv[6] : nullptr;
        const char *detectorType = (argc == 8) ? argv[7] : nullptr;
        Runner<Handbook> runner(argv[1], atoi(argv[2]), atoi(argv[3]), atof(argv[4]), atof(argv[5]), volumeSaverType, detectorType);
        run(runner);
    }
    catch (Error error)
    {
        std::cerr << "Run error:\n  " << error.message() << std::endl;
    }

    return 0;
}
