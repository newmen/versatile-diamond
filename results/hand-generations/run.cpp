#include "run.h"
#include "phases/diamond.h"
#include "handbook.h"

void run(Runner &runner)
{
    runner.calculate<Diamond, Handbook>();
}
