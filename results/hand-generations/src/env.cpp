#include "env.h"

YAMLConfigReader Env::__config("configs/env.yml");

double Env::R()
{
    static double value = __config.read<double>("R");
    return value;
}

double Env::gasT()
{
    static double value = __config.read<double>("temperature", "gas");
    return value;
}

double Env::surfaceT()
{
    static double value = __config.read<double>("temperature", "surface");
    return value;
}

double Env::cH()
{
    static double value = __config.read<double>("concentrations", "H");
    return value;
}

double Env::cCH3()
{
    static double value = __config.read<double>("concentrations", "CH3");
    return value;
}
