#include "base_spec.h"

namespace vd
{

void BaseSpec::store()
{
#ifdef PRINT
    this->wasFound();
#endif // PRINT

    assert(!isVisited());
    findChildren();
}

void BaseSpec::remove()
{
#ifdef PRINT
    wasForgotten();

    debugPrint([&](std::ostream &os) {
        os << "Removing reactions for " << this->name() << " with atoms of: " << std::endl;
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
