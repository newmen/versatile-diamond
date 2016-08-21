#include <signal.h>
#include <tools/preparator.h>
#include "handbook.h"

using namespace vd;

void stopSignalHandler(int)
{
    Runner<Handbook>::stop();
}

int main(int argc, char *argv[])
{
    std::cout.precision(3);

    if (argc > 3)
    {
        std::cerr << "Wrong number of run arguments!" << std::endl;
        std::cout << "Try: " << argv[0] << " run_name" << std::endl;
        return 1;
    }

    signal(SIGINT, stopSignalHandler);
    signal(SIGTERM, stopSignalHandler);

    try
    {
        Preparator<Handbook> preparator(argc, argv);
        preparator.runner()->calculate();
    }
    catch (Error error)
    {
        std::cerr << "Run error:\n  " << error.message() << std::endl;
    }

    return 0;
}
