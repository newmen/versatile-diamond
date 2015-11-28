#include "debug_print.h"

#ifdef PRINT

namespace vd
{

IndentStream rootStream(std::ostringstream &stream)
{
    return IndentStream(stream, 0);
}

IndentStream indentStream(IndentStream &stream)
{
    return IndentStream(stream, 2);
}

}

#endif // PRINT
