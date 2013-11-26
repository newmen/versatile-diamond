#ifndef DEBUG_PRINT_H
#define DEBUG_PRINT_H

#ifdef PRINT

#include <iostream>

#ifdef PARALLEL
#include <omp.h>
#endif // PARALLEL

namespace vd
{

template <class L>
void debugPrintWoLock(const L &lambda, bool putsNewLine = true)
{
#ifdef PARALLEL
    std::cout << "№" << omp_get_thread_num() << ": ";
#endif // PARALLEL

    lambda(std::cout);
    if (putsNewLine)
    {
        std::cout << std::endl;
    }
}

template <class L>
void debugPrint(const L &lambda, bool putsNewLine = true)
{
    {
#ifdef PARALLEL
#pragma omp critical (print)
#endif // PARALLEL
        debugPrintWoLock(lambda, putsNewLine);
    }
}

}

#endif // PRINT

#endif // DEBUG_PRINT_H
