#ifndef DEBUG_PRINT_H
#define DEBUG_PRINT_H

#include "define_print.h"
#ifdef ANY_PRINT

#include <iostream>
#include <sstream>
#include <fstream>
#include "indent_stream.h"

namespace vd
{

class DebugOutFlag
{
    static bool _needOutToDebug;

public:
    static void switchFlag(bool newValue);
    static bool isDebugOut();
};

//////////////////////////////////////////////////////////////////////////////////////

IndentStream rootStream(std::ostringstream &stream);
IndentStream indentStream(IndentStream &stream);

std::ostream &debugStream();

template <class L>
void debugPrint(const L &lambda)
{
    if (!DebugOutFlag::isDebugOut()) return;

    std::ostringstream stringStream;
    IndentStream smartStream = rootStream(stringStream);

    lambda(smartStream);

    debugStream() << stringStream.str() << "\n";
}

}

#endif // ANY_PRINT
#endif // DEBUG_PRINT_H
