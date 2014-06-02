#include <cmath>
#include "rates_reader.h"
#include "../env.h"

YAMLConfigReader RatesReader::__config("configs/reactions.yml");

double RatesReader::getRate(const char *rid)
{
    double A = __config.read<double>(rid, "A");
    double Ea = __config.read<double>(rid, "Ea");
    double Tp = __config.read<double>(rid, "Tp");

    return A * std::pow(Env::T(), Tp) * std::exp(-Ea / (Env::R() * Env::T()));
}
