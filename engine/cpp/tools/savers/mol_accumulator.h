#ifndef MOL_ACCUMULATOR_H
#define MOL_ACCUMULATOR_H

#include "accumulator.h"

namespace vd
{

class MolAccumulator : public Accumulator
{
    uint _atomsNum = 0;
    uint _bondsNum = 0;

    typedef std::unordered_map<AtomInfo, uint> AtomInfos;
    AtomInfos _atoms;

    typedef std::unordered_map<BondInfo, uint> BondInfos;
    BondInfos _bonds;

public:
    explicit MolAccumulator(const Detector *detector) : Accumulator(detector) {}

    const BondInfos &bonds() const { return _bonds; }
    const AtomInfos &atoms() const { return _atoms; }

protected:
    void treatHidden(const Atom *first, const Atom *second) override;
    void pushPair(const Atom *from, const Atom *to) override;

private:
    MolAccumulator(const MolAccumulator &) = delete;
    MolAccumulator(MolAccumulator &&) = delete;
    MolAccumulator &operator = (const MolAccumulator &) = delete;
    MolAccumulator &operator = (MolAccumulator &&) = delete;

    AtomInfo &findOrCreateAI(const Atom *atom);

    uint aiIndex(const AtomInfo &ai) const;
    uint biIndex(const BondInfo &bi) const;

    bool isNear(const Atom *first, const Atom *second) const;
    Lattice *latticeFor(const Atom *atom) const;
};

}

#endif // MOL_ACCUMULATOR_H
