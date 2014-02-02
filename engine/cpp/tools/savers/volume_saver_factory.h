#ifndef VOLUME_SAVER_FACTORY_H
#define VOLUME_SAVER_FACTORY_H

#include <memory>
#include "../factory.h"
#include "mol_saver.h"

namespace vd
{

class VolumeSaverFactory : public Factory<MolSaver, std::string, const char *>
{
public:
    VolumeSaverFactory();
};

}

#endif // VOLUME_SAVER_FACTORY_H
