#ifndef ENV_H
#define ENV_H

#include <tools/yaml_config_reader.h>
using namespace vd;

class Env
{
public:
    static double R();

    static double gasT();
    static double surfaceT();

    static double cH();
    static double cCH3();

private:
    static YAMLConfigReader &config();
};

#endif // ENV_H
