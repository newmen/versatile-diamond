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

    debugPrint([&](IndentStream &os) {
        os << "BaseSpec::remove " << this->name() << " with atoms of: " << std::endl;
        os << std::dec;
        this->eachAtom([&os](Atom *atom) {
            atom->info(os);
            os << std::endl;
        });
    });
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
