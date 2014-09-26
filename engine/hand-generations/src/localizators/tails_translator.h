#ifdef NEYRON
#ifndef TAILS_TRANSLATOR_H
#define TAILS_TRANSLATOR_H

#include <unordered_map>
#include <tools/common.h>
using namespace vd;

class TailsTranslator
{
    typedef std::unordered_map<ushort, ushort> TypeToTail;
    TypeToTail _typeToTail;

public:
    TailsTranslator();
    ushort translate(ushort type) const;
};

#endif // TAILS_TRANSLATOR_H
#endif // NEYRON
