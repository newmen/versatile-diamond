#include "saving_atom.h"
#include "atom.h"
#include "../phases/saving_crystal.h"

namespace vd
{

SavingAtom::SavingAtom(const Atom *original, OriginalLattice *lattice) :
    BaseAtom(original->type(), original->valence(), lattice),
    _name(original->name()), _valence(original->valence())
{

}

void SavingAtom::setLattice(OriginalLattice *lattice)
{
    BaseAtom::setLattice(lattice);
}

float3 SavingAtom::realPosition() const
{
    if (lattice())
    {
        return relativePosition() + lattice()->crystal()->correct(this);
    }
    else
    {
        return relativePosition();
    }
}

float3 SavingAtom::relativePosition() const
{
    if (lattice())
    {
        return lattice()->crystal()->translate(lattice()->coords());
    }
    else
    {
        return correctAmorphPos();
    }
}

float3 SavingAtom::correctAmorphPos() const
{
    const float amorphBondLength = 1.7;

    float3 position;
    auto goodRelatives = goodCrystalRelatives();
    uint counter = goodRelatives.size();

    for (const SavingAtom *nbr : goodRelatives)
    {
        position += nbr->relativePosition(); // should be used realPosition() if correct behavior of additionHeight() for case when counter == 1;
    }

    if (counter == 1)
    {
        // TODO: targets to another atoms of...
        position.z += amorphBondLength;
    }
    else if (counter == 2)
    {
        position /= 2;

        const float3 frl = goodRelatives[0]->relativePosition();
        const float3 srl = goodRelatives[1]->relativePosition();

        double l = frl.length(srl);
        assert(l > 0);
        double halfL = l * 0.5;
        assert(halfL < amorphBondLength);

        double diffZ = frl.z - srl.z;
        double smallXY = amorphBondLength * diffZ / l;
        double angleXY = std::atan((frl.y - srl.y) / (frl.x - srl.x));
        position.x += smallXY / std::cos(angleXY);
        position.y += smallXY / std::sin(angleXY);

        double tiltedH = std::sqrt(amorphBondLength * amorphBondLength - halfL * halfL);
        double angleH = (std::abs(diffZ) < 1e-3) ? 0 : std::asin(l / diffZ);
        position.z += tiltedH / std::cos(angleH);
    }
    else
    {
        assert(goodRelatives.size() > 2);

        const float3 &frl = goodRelatives[0]->relativePosition();
        const float3 &srl = goodRelatives[1]->relativePosition();
        const float3 &trl = goodRelatives[2]->relativePosition();

        double a = frl.length(srl);
        double b = frl.length(trl);
        double c = srl.length(trl);
        double p = (a + b + c) * 0.5;

        double r = 0.25 * a * b * c / std::sqrt(p * (p - a) * (p - b) * (p - c));
        assert(r < amorphBondLength);

        double tiltedH = std::sqrt(amorphBondLength * amorphBondLength - r * r);
        // ...
        assert(false); // there should be juicy code
    }

    return position;
}

std::vector<const SavingAtom *> SavingAtom::goodCrystalRelatives() const
{
    assert(!lattice());

    const ushort crystNNs = crystalNeighboursNum();
    const int3 *crystalCrds = nullptr;

    std::vector<const SavingAtom *> result;
    for (const SavingAtom *nbr : relatives())
    {
        if (!crystalCrds && nbr->lattice())
        {
            crystalCrds = &nbr->lattice()->coords();
        }
        else if (nbr->lattice())
        {
            int3 diff = *crystalCrds - nbr->lattice()->coords();
            if (!diff.isUnit()) continue;
        }

        ushort nbrCrystNNs = nbr->crystalNeighboursNum();
        if (crystNNs < nbrCrystNNs || (crystNNs == nbrCrystNNs && bonds() < nbr->bonds()))
        {
            if (std::find(result.cbegin(), result.cend(), nbr) == result.cend())
            {
                result.push_back(nbr);
            }
        }
    }

    return result;
}

}
