#include "base_spec.h"
#include "../atoms/atom.h"

namespace vd
{

void BaseSpec::store()
{
#if defined(PRINT) || defined(SPEC_PRINT)
    this->wasFound();
#endif // PRINT || SPEC_PRINT

    findChildren();
}

void BaseSpec::remove()
{
#if defined(PRINT) || defined(SPEC_PRINT)
    wasForgotten();
#endif // PRINT || SPEC_PRINT
}

#if defined(PRINT) || defined(SPEC_PRINT)
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
#endif // PRINT || SPEC_PRINT

}
