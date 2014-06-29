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
    void writeTo(std::ostream &os, const char *prefix, const Detector *detector) const;

private:
    AtomInfo &findAI(const Atom *atom);
    uint aiIndex(const AtomInfo &ai) const;
    uint biIndex(const BondInfo &bi) const;

    bool isNear(const Atom *first, const Atom *second) const;
    void writeCounts(std::ostream &os, const char *prefix) const;
    void writeAtoms(std::ostream &os, const char *prefix, const Detector *detector) const;
    void writeBonds(std::ostream &os, const char *prefix) const;
};

}

#endif // MOL_ACCUMULATOR_H
