#ifndef ENV_H
#define ENV_H

#include <tools/yaml_config_reader.h>
using namespace vd;

class Env
{
    static YAMLConfigReader __config;

public:
    static double R();
    static double T();

    static double cH();
    static double cCH3();
};

#endif // ENV_H
