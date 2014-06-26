#ifndef VOLUME_SAVER_FACTORY_H
#define VOLUME_SAVER_FACTORY_H

#include <memory>
#include "../factory.h"
#include "named_saver.h"

namespace vd
{

class VolumeSaverFactory : public Factory<NamedSaver, std::string, const char *>
{
public:
    VolumeSaverFactory();
};

}

#endif // VOLUME_SAVER_FACTORY_H
