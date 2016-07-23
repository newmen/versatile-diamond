#include <cmath>
#include "rates_reader.h"

YAMLConfigReader RatesReader::__config("configs/reactions.yml");

double RatesReader::getRate(const char *rid)
{
    return arrenius(rid, Env::surfaceT());
}

void RatesReader::readParams(const char *rid, double *k, double *Ea, double *Tp)
{
    *k = __config.read<double>(rid, "k");
    *Ea = __config.read<double>(rid, "Ea");
    *Tp = __config.read<double>(rid, "Tp");
}

double RatesReader::arrenius(const char *rid, double t)
{
    double k, Ea, Tp;
    readParams(rid, &k, &Ea, &Tp);

    return k * std::pow(t, Tp) * std::exp(-Ea / (Env::R() * t));
}

double RatesReader::product(double acc, double first)
{
    return acc * first;
}
