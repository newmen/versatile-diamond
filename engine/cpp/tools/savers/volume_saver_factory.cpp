#include "volume_saver_factory.h"
#include "sdf_saver.h"
#include "surface_detector.h"

namespace vd
{

VolumeSaverFactory::VolumeSaverFactory()
{
    registerNewType<MolSaver<SurfaceDetector>>("mol");
    registerNewType<SdfSaver<SurfaceDetector>>("sdf");
}

}
