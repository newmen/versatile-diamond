#ifndef VOLUME_SAVER_FACTORY_H
#define VOLUME_SAVER_FACTORY_H

#include <memory>
#include "../factory.h"
#include "volume_saver.h"

namespace vd
{

class VolumeSaverFactory : public Factory<VolumeSaver, std::string, const char *>
{
public:
    VolumeSaverFactory();

private:
    VolumeSaverFactory(const VolumeSaverFactory &) = delete;
    VolumeSaverFactory(VolumeSaverFactory &&) = delete;
    VolumeSaverFactory &operator = (const VolumeSaverFactory &) = delete;
    VolumeSaverFactory &operator = (VolumeSaverFactory &&) = delete;
};

}

#endif // VOLUME_SAVER_FACTORY_H
