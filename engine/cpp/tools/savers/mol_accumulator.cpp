#include "mol_accumulator.h"
#include <cmath>
#include "mol_format.h"

namespace vd
{

MolAccumulator::~MolAccumulator()
{
    for (auto &pair : _atomsToInfos)
    {
        delete pair.second;
    }

    for (auto &pair : _bondKeysToInfos)
    {
        delete pair.second;
    }
}

void MolAccumulator::treatHidden(const Atom *first, const Atom *second)
{
    if (!detector()->isShown(first) && detector()->isShown(second))
    {
        checkOrAddAtom(second);
        _atomsToInfos[second]->incNoBond();
    }
}

void MolAccumulator::pushPair(const Atom *from, const Atom *to)
{
    checkOrAddAtom(from);
    checkOrAddAtom(to);

    uint fi = _atomsToNums.find(from)->second;
    uint ti = _atomsToNums.find(to)->second;

    assert(fi != ti);
    if (fi > ti) return;

    if (!isNear(from, to))
    {
        _atomsToInfos[from]->incNoBond();
        _atomsToInfos[to]->incNoBond();
    }
    else
    {
        checkOrIncBond(fi, ti);
    }
}

void MolAccumulator::checkOrAddAtom(const Atom *atom)
{
    if (_atomsToNums.find(atom) == _atomsToNums.cend())
    {
        assert(_atomsToInfos.find(atom) == _atomsToInfos.cend());

        _atomsToNums.insert(AtomsToNums::value_type(atom, _atomsToNums.size() + 1));
        _atomsToInfos.insert(AtomsToInfos::value_type(atom, new AtomInfo(atom)));
    }
}

void MolAccumulator::checkOrIncBond(uint fi, uint ti)
{
    BondKey bk = makeBondKey(fi, ti);
    auto it = _bondKeysToInfos.find(bk);
    if (it == _bondKeysToInfos.cend())
    {
        assert(_bondKeysToNums.find(bk) == _bondKeysToNums.cend());

        _bondKeysToNums.insert(BondKeysToNums::value_type(bk, _bondKeysToNums.size() + 1));
        _bondKeysToInfos.insert(BondKeysToInfos::value_type(bk, new BondInfo(fi, ti)));
    }
    else
    {
        it->second->incArity();
    }
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
