#include "savers_builder.h"

SaversBuilder::SaversBuilder()
{

}

VolumeSaver SaversBuilder::createVolumeSaver(std::string volumeSaverType, std::string filename)
{
    if (!vsFactory.isRegistered(volumeSaverType))
    {
        throw Error("Undefined type of volume file saver");
    }
    return _vsFactory.create(volumeSaverType, filename().c_str()); //filename?
}

SaversBuilder::~SaversBuilder()
{

}

