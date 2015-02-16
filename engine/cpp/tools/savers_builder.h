#ifndef SAVERSBUILDER_H
#define SAVERSBUILDER_H

#include "savers/volume_saver.h"
#include "savers/volume_saver_factory.h"
#include "savers/detector_factory.h"
#include "savers/detector.h"
#include "dump/dump_saver.h"

class SaversBuilder
{
    VolumeSaverFactory _vsFactory;

public:
    SaversBuilder();

    VolumeSaver createVolumeSaver(std::string volumeSaverType, std::string filename);

    ~SaversBuilder();
};

#endif // SAVERSBUILDER_H
