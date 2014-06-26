#ifndef MOL_ACCUMULATOR_H
#define MOL_ACCUMULATOR_H

#include <ostream>
#include <unordered_map>
#include "atom_info.h"
#include "bond_info.h"

namespace vd
{

class MolAccumulator
{
    uint _atomsNum = 0;
    uint _bondsNum = 0;

    typedef std::unordered_map<AtomInfo, uint> AtomInfos;
    AtomInfos _atoms;

    typedef std::unordered_map<BondInfo, uint> BondInfos;
    BondInfos _bonds;

public:
    MolAccumulator();

    void addBond(const Atom *from, const Atom *to);

    template <class D>
    void writeTo(std::ostream &os, const char *prefix) const;

private:
    AtomInfo &findAI(const Atom *atom);
    uint aiIndex(const AtomInfo &ai) const;
    uint biIndex(const BondInfo &bi) const;

    bool isNear(const Atom *first, const Atom *second) const;

    void writeCounts(std::ostream &os, const char *prefix) const;

    template <class D>
    void writeAtoms(std::ostream &os, const char *prefix) const;

    void writeBonds(std::ostream &os, const char *prefix) const;
};

////////////////////////////////////////////////////////////////////////////

template <class D>
void MolAccumulator::writeTo(std::ostream &os, const char *prefix) const
{
    writeCounts(os, prefix);
    writeAtoms<D>(os, prefix);
    writeBonds(os, prefix);
}

template <class D>
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
           << ai->options<D>() << "\n";
    }
    os << prefix << "END ATOM" << "\n";
}

}

#endif // MOL_ACCUMULATOR_H
