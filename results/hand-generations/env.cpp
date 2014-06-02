#include "env.h"

YAMLConfigReader Env::__config("configs/env.yml");

double Env::R()
{
    static double value = __config.read<double>("R");
    return value;
}

double Env::T()
{
    static double value = __config.read<double>("T");
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
