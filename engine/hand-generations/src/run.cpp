#include "run.h"
#include "phases/diamond.h"
#include "handbook.h"
#include "tools/savers/surface_detector.h"

void run(Runner &runner)
{
    const SurfaceDetector<24> detector;
    const std::initializer_list<ushort> types = { 0, 2, 4, 5, 20, 21, 24, 28, 32 };
    runner.calculate<Diamond, Handbook>(&detector, types);
}
