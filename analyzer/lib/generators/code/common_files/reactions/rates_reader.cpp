#include <cmath>
#include "rates_reader.h"
#include "../handbook.h"

double RatesReader::getRate(const char *rid)
{
    return arrenius(rid, Env::surfaceT());
}

YAMLConfigReader &RatesReader::config()
{
    static YAMLConfigReader instance(Handbook::ratesConfigPath());
    return instance;
}

void RatesReader::readParams(const char *rid, double *k, double *Ea, double *Tp)
{
    *k = config().read<double>(rid, "k");
    *Ea = config().read<double>(rid, "Ea");
    *Tp = config().read<double>(rid, "Tp");
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
