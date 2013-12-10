#include "base_spec.h"

#ifdef PRINT
#include "../tools/debug_print.h"
#endif // PRINT

namespace vd
{

void BaseSpec::findChildren()
{
    findAllChildren();
    setVisited();
}

#ifdef PRINT
void BaseSpec::wasFound()
{
    debugPrint([&](std::ostream &os) {
        info(os);
        os << " was found";
    });
}

void BaseSpec::wasForgotten()
{
    debugPrint([&](std::ostream &os) {
        info(os);
        os << " was forgotten";
    });
}
#endif // PRINT

}
