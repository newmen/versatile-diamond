#ifndef DEBUG_PRINT_H
#define DEBUG_PRINT_H

#include "define_print.h"

#if defined(PRINT) || defined(ANY_PRINT)

#include <iostream>
#include <sstream>
#include <fstream>
#include "indent_stream.h"

namespace vd
{

IndentStream rootStream(std::ostringstream &stream);
IndentStream indentStream(IndentStream &stream);

std::ostream &debugStream();

template <class L>
void debugPrint(const L &lambda)
{
    std::ostringstream stringStream;
    IndentStream smartStream = rootStream(stringStream);

    lambda(smartStream);

    debugStream() << stringStream.str() << "\n";
}

}

#endif // PRINT || ANY_PRINT
#endif // DEBUG_PRINT_H
