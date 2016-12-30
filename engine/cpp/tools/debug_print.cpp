#include "define_print.h"

#if defined(PRINT) || defined(ANY_PRINT)

#include "debug_print.h"
#include <streambuf>

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

std::ostream &debugStream()
{
    static std::ofstream out("debug.log");
    return out;
}

}

#endif // PRINT || ANY_PRINT
