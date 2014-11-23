#ifdef NEYRON
#include "tails_translator.h"
#include "../handbook.h"

TailsTranslator::TailsTranslator()
{
    for (uint i = 0; i < Handbook::__tailStatesNum; ++i)
    {
        ushort key = Handbook::__tailStates[i];
        _typeToTail.insert(TypeToTail::value_type(key, i+1));
    }
}

ushort TailsTranslator::translate(ushort type) const
{
    return _typeToTail.find(type)->second;
}
#endif // NEYRON
