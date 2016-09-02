#include "base_spec.h"
#include "../atoms/atom.h"

namespace vd
{

void BaseSpec::store()
{
#ifdef PRINT
    this->wasFound();
#endif // PRINT

    findChildren();
}

void BaseSpec::remove()
{
#ifdef PRINT
    wasForgotten();
#endif // PRINT
}

#ifdef PRINT
void BaseSpec::wasFound()
{
    debugPrint([&](IndentStream &os) {
        info(os);
        os << " was found";
    });
}

void BaseSpec::wasForgotten()
{
    debugPrint([&](IndentStream &os) {
        info(os);
        os << " was forgotten";
    });
}
#endif // PRINT

}
