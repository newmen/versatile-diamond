#include "mol_accumulator.h"
#include <cmath>
#include <vector>

namespace vd
{

MolAccumulator::MolAccumulator()
{
}

void MolAccumulator::addBond(const Atom *from, const Atom *to)
{
    uint first = atomIndex(from);
    uint second = atomIndex(to);

    if (!isNear(from, to)) return;

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

void MolAccumulator::writeTo(std::ostream &os, const char *prefix) const
{
    writeCounts(os, prefix);
    writeAtoms(os, prefix);
    writeBonds(os, prefix);
}

uint MolAccumulator::atomIndex(const Atom *atom)
{
    AtomInfo ai(atom);
    auto it = _atoms.find(ai);
    if (it != _atoms.cend())
    {
        return it->second;
    }
    else
    {
        _atoms.insert(AtomInfos::value_type(ai, ++_atomsNum));
        return _atomsNum;
    }
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
    if (first->lattice() && second->lattice())
    {
        auto &fc = first->lattice()->coords(), &sc = second->lattice()->coords();
        if (fabs(fc.x - sc.x) > 1 || fabs(fc.y - sc.y) > 1)
        {
            return false;
        }
    }
    return true;
}

void MolAccumulator::writeCounts(std::ostream &os, const char *prefix) const
{
    os << prefix << "COUNTS " << _atomsNum << " " << _bondsNum << " " << "0 0 0" << "\n";
}

void MolAccumulator::writeAtoms(std::ostream &os, const char *prefix) const
{
    os << prefix << "BEGIN ATOM" << "\n";

    std::vector<const AtomInfo *> orderer(_atoms.size());
    for (auto &pr : _atoms) orderer[pr.second - 1] = &pr.first;

    for (const AtomInfo *ai : orderer)
    {
        const float3 &coords = ai->coords();

        os << prefix
           << aiIndex(*ai) << " "
           << ai->type() << " "
           << coords.x << " "
           << coords.y << " "
           << coords.z << " "
           << "0"
           << ai->options() << "\n";
    }
    os << prefix << "END ATOM" << "\n";
}

void MolAccumulator::writeBonds(std::ostream &os, const char *prefix) const
{
    os << prefix << "BEGIN BOND" << "\n";

    std::vector<const BondInfo *> orderer(_bonds.size());
    for (auto &pr : _bonds) orderer[pr.second - 1] = &pr.first;

    for (const BondInfo *bi : orderer)
    {
        os << prefix
           << biIndex(*bi) << " "
           << bi->type() << " "
           << bi->from() << " "
           << bi->to()
           << bi->options() << "\n";
    }
    os << prefix << "END BOND" << "\n";
}

}
