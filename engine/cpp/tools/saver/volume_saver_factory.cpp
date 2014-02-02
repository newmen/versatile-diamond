#include "volume_saver_factory.h"
#include "sdf_saver.h"

namespace vd
{

VolumeSaverFactory::VolumeSaverFactory()
{
    registerNewType<MolSaver>("mol");
    registerNewType<SdfSaver>("sdf");
}

bool VolumeSaverFactory::isRegistered(const std::string &id) const
{
    return Factory::isRegistered(id);
}

std::shared_ptr<MolSaver> VolumeSaverFactory::create(const std::string &id, const char *name) const
{
    return std::shared_ptr<MolSaver>(Factory::create(id, name));
}

}
