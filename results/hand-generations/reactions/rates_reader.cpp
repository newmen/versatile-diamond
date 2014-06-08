#include <cmath>
#include "rates_reader.h"
#include "../env.h"

YAMLConfigReader RatesReader::__config("configs/reactions.yml");

double RatesReader::getRate(const char *rid)
{
    return arrenius(rid, Env::surfaceT());
}

void RatesReader::readParams(const char *rid, double *A, double *Ea, double *Tp)
{
    *A = __config.read<double>(rid, "A");
    *Ea = __config.read<double>(rid, "Ea");
    *Tp = __config.read<double>(rid, "Tp");
}

double RatesReader::arrenius(const char *rid, double t)
{
    double A, Ea, Tp;
    readParams(rid, &A, &Ea, &Tp);

    return A * std::pow(t, Tp) * std::exp(-Ea / (Env::R() * t));
}

double RatesReader::product(double acc, double first)
{
    return acc * first;
}
