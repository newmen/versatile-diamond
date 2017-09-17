#include <signal.h>
#include <vector>
#include <yaml-cpp/yaml.h>
#include <tools/preparator.h>
#include "handbook.h"

#define ERROR_CODE 1

using namespace vd;

void stopSignalHandler(int)
{
    Runner<Handbook>::stop();
}

Runner<Handbook> *safeGetRunner(Preparator<Handbook> *preparator)
{
    try
    {
        return preparator->runner(); // Sub-thread initialization
    }
    catch (Error error)
    {
        std::cerr << "Run error:\n  " << error.message() << std::endl;
        return nullptr;
    }
}

int firmRun(Preparator<Handbook> *preparator, const std::vector<int> &signalIDs)
{
    sigset_t blindSet, defaultSet;
    sigemptyset(&blindSet);
    for (int sID : signalIDs) sigaddset(&blindSet, sID);
    // Preconfigure signals handler for spawning threads
    pthread_sigmask(SIG_BLOCK, &blindSet, &defaultSet);

    // Initiate calculation system
    Runner<Handbook> *runner = safeGetRunner(preparator);
    if (runner)
    {
        // Get back default signals handler
        pthread_sigmask(SIG_SETMASK, &defaultSet, nullptr);
        // Mark global signals handler (for main thread)
        for (int sID : signalIDs) signal(sID, stopSignalHandler);

        // Do simulation
        runner->calculate();
        return 0;
    }
    else
    {
        return ERROR_CODE;
    }
}

int safeRun(int argc, char const *argv[])
{
    if (argc == 3)
    {
        Handbook::setConfigsDir(argv[2]);
    }
    try
    {
        Preparator<Handbook> preparator(argv[1]);
        return firmRun(&preparator, {
            SIGINT, SIGQUIT, SIGKILL, SIGSEGV, SIGTERM, SIGSTOP, SIGTSTP, SIGCHLD
        });
    }
    catch (YAML::BadFile)
    {
        std::cerr << "Wrong config directory: " << argv[2] << std::endl;
        return ERROR_CODE;
    }
}

int main(int argc, char const *argv[])
{
    if (argc == 2 || argc == 3)
    {
        std::cout.precision(3);
        return safeRun(argc, argv);
    }
    else
    {
        std::cerr << "Wrong number of run arguments!" << std::endl;
        std::cout << "Try: " << argv[0] << " run_name [path/to/configs/dir]" << std::endl;
        return ERROR_CODE;
    }
}
