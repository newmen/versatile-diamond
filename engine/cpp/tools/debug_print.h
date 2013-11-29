#ifndef DEBUG_PRINT_H
#define DEBUG_PRINT_H

#ifdef PRINT

#include <iostream>
#include <sstream>

#ifdef PARALLEL
#include <omp.h>
#endif // PARALLEL

namespace vd
{

template <class L>
void debugPrint(const L &lambda, bool putsNewLine = true)
{
#ifdef PARALLEL
#pragma omp critical (print)
#endif // PARALLEL
    {
        std::stringstream ss;

#ifdef PARALLEL
        ss << "№" << omp_get_thread_num() << ": ";
#endif // PARALLEL

        lambda(ss);
        if (putsNewLine)
        {
            ss << "\n";
        }

        std::cout << ss.str();
    }
}

}

#endif // PRINT

#endif // DEBUG_PRINT_H
