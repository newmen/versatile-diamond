#ifndef INIT_CONFIG_H
#define INIT_CONFIG_H

#include <cstdlib>
#include "common.h"
#include "../hand-generations/src/handbook.h"
#include "savers/volume_saver.h"
#include "savers/detector.h"
#include "error.h"

using namespace vd;

struct InitConfig
{
    const std::string name;
    const uint x, y;
    const double totalTime, eachTime;
    const Detector *detector = nullptr;
    const Behavior *behavior = nullptr;
    VolumeSaver *volumeSaver = nullptr;

    InitConfig(int argc, char *argv[]);
    ~InitConfig();

    std::string filename() const;
};


#endif // INIT_CONFIG_H
