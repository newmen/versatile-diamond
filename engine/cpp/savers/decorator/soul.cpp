#include "soul.h"

namespace vd {

Soul::~Soul()
{
    delete _copyAmorph;
    delete _copyCrystal;
}

void Soul::copyData()
{
    auto tpl = copyAtoms(_origCrystal, _origAmorph);
    _copyCrystal = std::get<0>(tpl);
    _copyAmorph = std::get<1>(tpl);
}

typename Soul::SavingPhases Soul::copyAtoms(const Crystal *crystal, const Amorph *amorph) const
{
    std::unordered_map<const Atom *, SavingAtom *> mirror;
    mirror.reserve(crystal->maxAtoms() + amorph->countAtoms());

    SavingCrystal *savingCrystal = new SavingCrystal(crystal);
    SavingAmorph *savingAmorph = new SavingAmorph();

    auto fillLambda = [&mirror, savingCrystal, savingAmorph](const Atom *atom) {
        SavingAtom *sa = new SavingAtom(atom, nullptr);
        mirror[atom] = sa;

        auto originalLattice = atom->lattice();
        if (originalLattice) {
            savingCrystal->insert(sa, originalLattice->coords());
        } else {
            savingAmorph->insert(sa);
        }
    };

    crystal->eachAtom(fillLambda);
    amorph->eachAtom(fillLambda);

    auto copyRelationsLambda = [&mirror](const Atom *atom) {
        SavingAtom *target = mirror.find(atom)->second;
        atom->eachNeighbour([&mirror, target](const Atom *nbr) {
            target->bondWith(mirror.find(nbr)->second, 0);
        });
    };

    crystal->eachAtom(copyRelationsLambda);
    amorph->eachAtom(copyRelationsLambda);

    return std::make_tuple(savingCrystal, savingAmorph);
}

}
