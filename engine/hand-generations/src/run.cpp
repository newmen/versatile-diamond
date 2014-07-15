#include "run.h"
#include <tools/savers/actives_portion_counter.h>
#include <tools/savers/surface_detector.h>
#include "phases/diamond.h"
#include "handbook.h"

void run(Runner<Handbook> &runner)
{
    const std::initializer_list<ushort> types = { 0, 2, 4, 5, 20, 21, 24, 28, 32 };
    runner.calculate<Diamond>(types);
}
