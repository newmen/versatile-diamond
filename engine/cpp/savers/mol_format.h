#ifndef MOL_FORMAT_H
#define MOL_FORMAT_H

#include <sstream>
#include "../phases/saving_reactor.h"
#include "format.h"
#include "mol_accumulator.h"

namespace vd
{

template <class B>
class MolFormat : public Format<B, MolAccumulator>
{
    typedef Format<B, MolAccumulator> ParentType;

public:
    template <class... Args> MolFormat(Args... args) : ParentType(args...) {}

protected:
    void writeHeader(std::ostream &os, const SavingReactor *reactor) override;
    void writeBody(std::ostream &os, const SavingReactor *reactor) override;

private:
    const char *prefix() const;
    void writeBegin(std::ostream &os) const;
    void writeEnd(std::ostream &os) const;
    void writeCounts(std::ostream &os) const;
    void writeBonds(std::ostream &os) const;
    void writeAtoms(std::ostream &os) const;

    std::string atomsOptions(const AtomInfo *ai) const;
};

//////////////////////////////////////////////////////////////////////////////////////

template <class B>
void MolFormat<B>::writeHeader(std::ostream &os, const SavingReactor *reactor)
{
    os << this->config()->name() << " (" << reactor->currentTime() << " s)\n"
       << "Writen at " << this->timestamp() << "\n"
       << "Versatile Diamond MOLv3000 writer" << "\n"
       << "  0  0  0     0 0             999 V3000" << "\n";
}

template <class B>
void MolFormat<B>::writeBody(std::ostream &os, const SavingReactor *)
{
    writeBegin(os);
    writeCounts(os);
    writeAtoms(os);
    writeBonds(os);
    writeEnd(os);
}

template <class B>
const char *MolFormat<B>::prefix() const
{
    static const char value[] = "M  V30 ";
    return value;
}

template <class B>
void MolFormat<B>::writeBegin(std::ostream &os) const
{
    os << prefix() << "BEGIN CTAB" << "\n";
}

template <class B>
void MolFormat<B>::writeEnd(std::ostream &os) const
{
    os << prefix() << "END CTAB" << "\n"
       << "M  END" << std::endl;
}

template <class B>
void MolFormat<B>::writeCounts(std::ostream &os) const
{
    os << prefix()
       << "COUNTS " << this->accumulator()->atomsNum()
       << " " << this->accumulator()->bondsNum()
       << " " << "0 0 0" << "\n";
}

template <class B>
void MolFormat<B>::writeBonds(std::ostream &os) const
{
    os << prefix() << "BEGIN BOND" << "\n";
    this->accumulator()->orderedEachBondInfo([&os, this](uint i, const BondInfo *bi) {
        os << prefix()
           << i << " "
           << bi->type() << " "
           << bi->from() << " "
           << bi->to() << "\n";
    });
    os << prefix() << "END BOND" << "\n";
}

template <class B>
void MolFormat<B>::writeAtoms(std::ostream &os) const
{
    os << prefix() << "BEGIN ATOM" << "\n";
    this->accumulator()->orderedEachAtomInfo([&os, this](uint i, const AtomInfo *ai) {
        const float3 &coords = ai->atom()->realPosition();
        os << prefix()
           << i << " "
           << ai->atom()->name() << " "
           << coords.x << " "
           << coords.y << " "
           << coords.z << " "
           << "0"
           << atomsOptions(ai) << "\n";
    });
    os << prefix() << "END ATOM" << "\n";
}

template <class B>
std::string MolFormat<B>::atomsOptions(const AtomInfo *ai) const
{
    const SavingAtom *atom = ai->atom();
    bool isBottom = this->accumulator()->detector()->isBottom(atom);

    int hc = atom->hCount();
    if (hc == 0 || isBottom)
    {
        hc = -1;
    }

    std::stringstream ss;
    ss << " HCOUNT=" << hc;

    ushort ac = isBottom ? atom->valence() - atom->bonds() : atom->actives();
    ac += ai->noBond();
    assert(ac < atom->valence());

    if (ac > 0)
    {
        ss << " CHG=-" << ac;
    }

    return ss.str();
}

}

#endif // MOL_FORMAT_H
