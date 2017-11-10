#include "env.h"
#include "handbook.h"

double Env::R()
{
    static double value = config().read<double>("R");
    return value;
}

double Env::gasT()
{
    static double value = config().read<double>("temperature", "gas");
    return value;
}

double Env::surfaceT()
{
    static double value = config().read<double>("temperature", "surface");
    return value;
}

double Env::cH()
{
    static double value = config().read<double>("concentrations", "H");
    return value;
}

double Env::cCH3()
{
    static double value = config().read<double>("concentrations", "CH3");
    return value;
}

YAMLConfigReader &Env::config()
{
    static YAMLConfigReader instance(Handbook::envConfigPath());
    return instance;
}
