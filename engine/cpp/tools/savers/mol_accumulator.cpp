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
    assert(from != to);

    AtomInfo &fai = findAI(from);
    AtomInfo &sai = findAI(to);

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

AtomInfo &MolAccumulator::findAI(const Atom *atom)
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
    if (first->lattice() && second->lattice())
    {
        auto &fc = first->lattice()->coords(), &sc = second->lattice()->coords();
        if (std::fabs(fc.x - sc.x) > 1 || std::fabs(fc.y - sc.y) > 1)
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

void MolAccumulator::writeTo(std::ostream &os, const char *prefix, const Detector *detector) const
{
    writeCounts(os, prefix);
    writeAtoms(os, prefix, detector);
    writeBonds(os, prefix);
}

void MolAccumulator::writeAtoms(std::ostream &os, const char *prefix, const Detector *detector) const
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
           << ai->options(detector) << "\n";
    }
    os << prefix << "END ATOM" << "\n";
}

}
