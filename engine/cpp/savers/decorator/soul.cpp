#include "soul.h"

namespace vd {

Soul::~Soul()
{
    delete _copyAmorph;
    delete _copyCrystal;
}

void Soul::copyData()
{
    std::unordered_map<const Atom *, SavingAtom *> mirror;
    mirror.reserve(_origCrystal->maxAtoms() + _origAmorph->countAtoms());

    _copyCrystal = new SavingCrystal(_origCrystal);
    _copyAmorph = new SavingAmorph();

    auto fillLambda = [&mirror, this](const Atom *atom) {
        SavingAtom *sa = new SavingAtom(atom, nullptr);
        mirror[atom] = sa;

        auto originalLattice = atom->lattice();
        if (originalLattice) {
            _copyCrystal->insert(sa, originalLattice->coords());
        } else {
            _copyAmorph->insert(sa);
        }
    };

    _origCrystal->eachAtom(fillLambda);
    _origAmorph->eachAtom(fillLambda);

    auto copyRelationsLambda = [&mirror](const Atom *atom) {
        SavingAtom *target = mirror.find(atom)->second;
        atom->eachNeighbour([&mirror, target](const Atom *nbr) {
            target->bondWith(mirror.find(nbr)->second, 0);
        });
    };

    _origCrystal->eachAtom(copyRelationsLambda);
    _origAmorph->eachAtom(copyRelationsLambda);
}

}
