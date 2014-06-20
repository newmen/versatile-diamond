#ifndef RATES_READER_H
#define RATES_READER_H

#include <tools/yaml_config_reader.h>
using namespace vd;

#include "../env.h"

class RatesReader
{
    static YAMLConfigReader __config;

public:
    template <class... Args>
    static double getRate(const char *rid, Args... multipliers);
    static double getRate(const char *rid);

private:
    static void readParams(const char *rid, double *A, double *Ea, double *Tp);
    static double arrenius(const char *rid, double t);

    template <class... Args>
    static double productAll(double first, Args... multipliers);

    template <class... Args>
    static double product(double acc, double first, Args... multipliers);
    static double product(double acc, double first);
};

//////////////////////////////////////////////////////////////////////////////////////

template <class... Args>
double RatesReader::getRate(const char *rid, Args... multipliers)
{
    return arrenius(rid, Env::gasT()) * productAll(multipliers...);
}

template <class... Args>
double RatesReader::productAll(double first, Args... multipliers)
{
    return product(1, first, multipliers...);
}

template <class... Args>
double RatesReader::product(double acc, double first, Args... multipliers)
{
    return product(acc * first, multipliers...);
}

#endif // RATES_READER_H
