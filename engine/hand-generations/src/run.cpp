#include "run.h"
#include <tools/savers/actives_portion_counter.h>
#include <tools/savers/surface_detector.h>
#include "phases/diamond.h"
#include "handbook.h"

void run(Runner &runner)
{
    const ActivesPortionCounter apCounter({24});
    const SurfaceDetector<24> detector;
    const std::initializer_list<ushort> types = { 0, 2, 4, 5, 20, 21, 24, 28, 32 };
    runner.calculate<Diamond, Handbook>(&apCounter, &detector, types);
}
