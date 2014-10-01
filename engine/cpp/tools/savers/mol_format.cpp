#include "mol_format.h"
#include <sstream>

namespace vd
{

void MolFormat::render(std::ostream &os, double currentTime) const
{
    writeHeader(os, currentTime);
    writeBegin(os);
    writeCounts(os);
    writeAtoms(os);
    writeBonds(os);
    writeEnd(os);
}

void MolFormat::writeHeader(std::ostream &os, double currentTime) const
{
    os << saver().name() << " (" << currentTime << " s)\n"
       << "Writen at " << timestamp() << "\n"
       << "Versatile Diamond MOLv3000 writer" << "\n"
       << "  0  0  0     0 0             999 V3000" << "\n";
}

const char *MolFormat::prefix() const
{
    static const char value[] = "M  V30 ";
    return value;
}

void MolFormat::writeBegin(std::ostream &os) const
{
    os << prefix() << "BEGIN CTAB" << "\n";
}

void MolFormat::writeEnd(std::ostream &os) const
{
    os << prefix() << "END CTAB" << "\n"
       << "M  END" << std::endl;
}

void MolFormat::writeCounts(std::ostream &os) const
{
    os << prefix() << "COUNTS " << acc().atomsNum() << " " << acc().bondsNum() << " " << "0 0 0" << "\n";
}

void MolFormat::writeBonds(std::ostream &os) const
{
    os << prefix() << "BEGIN BOND" << "\n";
    acc().orderedEachBondInfo([&os, this](uint i, const BondInfo *bi) {
        os << prefix()
           << i << " "
           << bi->type() << " "
           << bi->from() << " "
           << bi->to() << "\n";
    });
    os << prefix() << "END BOND" << "\n";
}

void MolFormat::writeAtoms(std::ostream &os) const
{
    os << prefix() << "BEGIN ATOM" << "\n";
    acc().orderedEachAtomInfo([&os, this](uint i, const AtomInfo *ai) {
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

std::string MolFormat::atomsOptions(const AtomInfo *ai) const
{

    const Atom *atom = ai->atom();
    bool isBtm = acc().detector()->isBottom(atom);

    int hc = atom->hCount();
    if (hc == 0 || isBtm)
    {
        hc = -1;
    }

    std::stringstream ss;
    ss << " HCOUNT=" << hc;

    ushort ac = isBtm ? atom->valence() - atom->bonds() : atom->actives();
    ac += ai->noBond();
    assert(ac < atom->valence());

    if (ac > 0)
    {
        ss << " CHG=-" << ac;
    }

    return ss.str();
}

}
