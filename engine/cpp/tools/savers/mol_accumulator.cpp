#include "mol_accumulator.h"
#include <cmath>
#include "mol_format.h"

namespace vd
{

void MolAccumulator::treatHidden(const Atom *first, const Atom *second)
{
    if (!detector()->isShown(first) && detector()->isShown(second))
    {
        findOrCreateAI(second).incNoBond();
    }
}

void MolAccumulator::pushPair(const Atom *from, const Atom *to)
{
    AtomInfo &fai = findOrCreateAI(from);
    AtomInfo &sai = findOrCreateAI(to);

    uint first = aiIndex(fai);
    uint second = aiIndex(sai);

    if (first > second) return;

    if (!isNear(from, to))
    {
        fai.incNoBond();
        sai.incNoBond();
    }
    else
    {
        BondInfo bond(first, second);
        auto it = _bonds.find(bond);
        if (it != _bonds.cend())
        {
            const_cast<BondInfo &>(it->first).incArity();
        }
        else
        {
            _bonds.insert(BondInfos::value_type(bond, ++_bondsNum));
        }
    }
}

AtomInfo &MolAccumulator::findOrCreateAI(const Atom *atom)
{
    const AtomInfo *result;

    AtomInfo ai(atom);
    auto it = _atoms.find(ai);
    if (it != _atoms.cend())
    {
        result = &it->first;
    }
    else
    {
        result = &_atoms.insert(AtomInfos::value_type(ai, ++_atomsNum)).first->first;
    }

    return const_cast<AtomInfo &>(*result);
}

uint MolAccumulator::aiIndex(const AtomInfo &ai) const
{
    return _atoms.find(ai)->second;
}

uint MolAccumulator::biIndex(const BondInfo &bi) const
{
    return _bonds.find(bi)->second;
}

bool MolAccumulator::isNear(const Atom *first, const Atom *second) const
{
    Lattice *fl = latticeFor(first), *sl = latticeFor(second);
    if (fl && sl)
    {
        int3 diff = fl->coords() - sl->coords();
        if (!diff.isUnit())
        {
            return false;
        }
    }
    return true;
}

Lattice *MolAccumulator::latticeFor(const Atom *atom) const
{
    if (atom->lattice())
    {
        return atom->lattice();
    }
    else
    {
        const Atom *nbr = atom->firstCrystalNeighbour();
        return nbr ? nbr->lattice() : nullptr;
    }
}

}
