#ifndef RATES_READER_H
#define RATES_READER_H

#include <tools/yaml_config_reader.h>
using namespace vd;

class RatesReader
{
    static YAMLConfigReader __config;

public:
    static double getRate(const char *rid);
};

#endif // RATES_READER_H
