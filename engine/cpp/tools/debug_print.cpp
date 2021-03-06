#include "define_print.h"
#ifdef ANY_PRINT

#include "debug_print.h"
#include <streambuf>

namespace vd
{

bool DebugOutFlag::_needOutToDebug = true;

void DebugOutFlag::switchFlag(bool newValue)
{
    _needOutToDebug = newValue;
}

bool DebugOutFlag::isDebugOut()
{
    return _needOutToDebug;
}

//////////////////////////////////////////////////////////////////////////////////////

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

#endif // ANY_PRINT
