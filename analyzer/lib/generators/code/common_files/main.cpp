#include <signal.h>
#include <vector>
#include <tools/preparator.h>
#include "handbook.h"

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
        return 1;
    }
}

int main(int argc, char *argv[])
{
    std::cout.precision(3);

    if (argc == 2)
    {
        Preparator<Handbook> preparator(argc, argv);
        return firmRun(&preparator, {
            SIGINT, SIGQUIT, SIGKILL, SIGTERM, SIGSTOP, SIGTSTP, SIGCHLD
        });
    }
    else
    {
        std::cerr << "Wrong number of run arguments!" << std::endl;
        std::cout << "Try: " << argv[0] << " run_name" << std::endl;
        return 1;
    }
}
