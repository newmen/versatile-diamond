#ifndef DETECTOR_FACTORY_H
#define DETECTOR_FACTORY_H

#include <memory>
#include "../tools/factory.h"
#include "surface_detector.h"
#include "all_atoms_detector.h"

namespace vd
{

template <class HB>
class DetectorFactory : public Factory<Detector, std::string>
{
public:
    DetectorFactory();
};

//////////////////////////////////////////////////////////////////////

template <class HB>
DetectorFactory<HB>::DetectorFactory()
{
    registerNewType<SurfaceDetector<HB>>("surf");
    registerNewType<AllAtomsDetector>("all");
}

}
#endif // DETECTOR_FACTORY_H
