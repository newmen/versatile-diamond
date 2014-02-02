#ifndef VOLUME_SAVER_FACTORY_H
#define VOLUME_SAVER_FACTORY_H

#include <memory>
#include "../factory.h"
#include "mol_saver.h"

namespace vd
{

class VolumeSaverFactory : protected Factory<MolSaver, std::string, const char *>
{
public:
    VolumeSaverFactory();

    bool isRegistered(const std::string &id) const;
    std::shared_ptr<MolSaver> create(const std::string &id, const char *name) const;
};

}

#endif // VOLUME_SAVER_FACTORY_H
