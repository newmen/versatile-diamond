#ifndef MOL_ACCUMULATOR_H
#define MOL_ACCUMULATOR_H

#include <vector>
#include "accumulator.h"

namespace vd
{

class MolAccumulator : public Accumulator
{
    typedef std::unordered_map<const Atom *, uint> AtomsToNums;
    typedef std::unordered_map<const Atom *, AtomInfo *> AtomsToInfos;

    AtomsToNums _atomsToNums;
    AtomsToInfos _atomsToInfos;

    typedef uint BondKey;
    typedef std::unordered_map<BondKey, uint> BondKeysToNums;
    typedef std::unordered_map<BondKey, BondInfo *> BondKeysToInfos;

    BondKeysToNums _bondKeysToNums;
    BondKeysToInfos _bondKeysToInfos;

public:
    explicit MolAccumulator(const Detector *detector) : Accumulator(detector) {}
    ~MolAccumulator() override;

    uint atomsNum() const { return _atomsToNums.size(); }
    uint bondsNum() const { return _bondKeysToNums.size(); }

    template <class L> void orderedEachAtomInfo(const L &lambda) const;
    template <class L> void orderedEachBondInfo(const L &lambda) const;

protected:
    void treatHidden(const Atom *first, const Atom *second) override;
    void pushPair(const Atom *from, const Atom *to) override;

private:
    MolAccumulator(const MolAccumulator &) = delete;
    MolAccumulator(MolAccumulator &&) = delete;
    MolAccumulator &operator = (const MolAccumulator &) = delete;
    MolAccumulator &operator = (MolAccumulator &&) = delete;

    void checkOrAddAtom(const Atom *atom);
    void checkOrIncBond(uint fi, uint ti);
    BondKey makeBondKey(uint fi, uint ti) const { return (fi << 16) ^ ti; }

    bool isNear(const Atom *first, const Atom *second) const;
    Lattice *latticeFor(const Atom *atom) const;

    template <typename KT, class IT, class L>
    void orderedEach(const std::unordered_map<KT, uint> &toNums, const std::unordered_map<KT, IT *> &toInfos, const L &lambda) const;
};

//////////////////////////////////////////////////////////////////////////////////////

template <class L>
void MolAccumulator::orderedEachAtomInfo(const L &lambda) const
{
    orderedEach(_atomsToNums, _atomsToInfos, lambda);
}

template <class L>
void MolAccumulator::orderedEachBondInfo(const L &lambda) const
{
    orderedEach(_bondKeysToNums, _bondKeysToInfos, lambda);
}

template <typename KT, class IT, class L>
void MolAccumulator::orderedEach(const std::unordered_map<KT, uint> &toNums, const std::unordered_map<KT, IT *> &toInfos, const L &lambda) const
{
    uint n = toNums.size();
    std::vector<const IT *> ordered(n);
    for (auto &pair : toNums)
    {
        ordered[pair.second] = toInfos.find(pair.first)->second;
    }
    for (uint i = 0; i < n; ++i)
    {
        lambda(i, ordered[i]);
    }
}

}

#endif // MOL_ACCUMULATOR_H
