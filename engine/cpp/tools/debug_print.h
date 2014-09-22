#ifndef DEBUG_PRINT_H
#define DEBUG_PRINT_H

#ifdef PRINT

#include <iostream>
#include <sstream>

namespace vd
{

template <class L>
void debugPrint(const L &lambda, bool putsNewLine = true)
{
    std::stringstream ss;

    lambda(ss);
    if (putsNewLine)
    {
        ss << "\n";
    }

    std::cout << ss.str();
}

}

#endif // PRINT
#endif // DEBUG_PRINT_H
