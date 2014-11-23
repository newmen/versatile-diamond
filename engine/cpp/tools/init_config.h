#ifndef INIT_CONFIG_H
#define INIT_CONFIG_H

#include <cstdlib>
#include "common.h"

struct InitConfig
{
    const char *name;
    vd::uint x = 0, y = 0;
    double totalTime;
#ifndef NEYRON
    double eachTime;
    const char *volumeSaverType;
    const char *detectorType;
#endif // NEYRON
    const char *behavior;

    InitConfig(int argc, char *argv[])
    {
        name = argv[1];
        x = atoi(argv[2]);
        y = atoi(argv[3]);
        totalTime = atof(argv[4]);
#ifdef NEYRON
        behavior = (argc == 6) ? argv[5] : nullptr;
#else
        eachTime = atof(argv[5]);
        volumeSaverType = (argc >= 7) ? argv[6] : nullptr;
        detectorType = (argc == 8) ? argv[7] : nullptr;
        behavior = (argc == 9) ? argv[8] : nullptr;
#endif // NEYRON
    }
};

#endif // INIT_CONFIG_H
