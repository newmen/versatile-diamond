#ifndef DEBUG_PRINT_H
#define DEBUG_PRINT_H

#ifdef PRINT

#include <iostream>
#include <sstream>
#include "indent_stream.h"

namespace vd
{

IndentStream rootStream(std::ostringstream &stream);
IndentStream indentStream(IndentStream &stream);

template <class L>
void debugPrint(const L &lambda, bool putsNewLine = true)
{
    std::ostringstream stringStream;
    IndentStream smartStream = rootStream(stringStream);

    lambda(smartStream);

    std::cout << stringStream.str();
    if (putsNewLine)
    {
        std::cout << std::endl;
    }
}

}

#endif // PRINT
#endif // DEBUG_PRINT_H
