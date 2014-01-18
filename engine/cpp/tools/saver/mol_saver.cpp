#include "mol_saver.h"
#include <ctime>
#include <sstream>
#include <unordered_set>

namespace vd
{

MolSaver::MolSaver(const std::string &name) : _name(name)
{
}

MolSaver::~MolSaver()
{
}

void MolSaver::writeFrom(Atom *atom) const
{
    MolAccumulator acc;
    accumulateToFrom(acc, atom);

    std::ofstream out(filename());
    writeHeader(out);
    acc.writeTo(out, mainPrefix());
    writeFooter(out);
}

std::string MolSaver::filename() const
{
    std::stringstream ss;
    ss << name() << " " << timestamp() << ext();
    return ss.str();
}

void MolSaver::writeHeader(std::ostream &os) const
{
    os << "VD out " << name() << "\n"
       << "Writen at " << timestamp() << "\n"
       << "Versatile diamond MOLv3000 writer" << "\n"
       << "  0  0  0     0 0             999 V3000" << "\n"

       << mainPrefix() << "BEGIN CTAB" << "\n";
}

void MolSaver::writeFooter(std::ostream &os) const
{
    os << mainPrefix() << "END CTAB" << "\n"

       << "M  END" << std::endl;
}

const char *MolSaver::mainPrefix() const
{
    static const char prefix[] = "M  V30 ";
    return prefix;
}

std::string MolSaver::timestamp() const
{
    time_t rawtime;
    struct tm *timeinfo;
    char buffer[80];

    time(&rawtime);
    timeinfo = localtime(&rawtime);

    strftime(buffer, 80, "%d-%m-%Y %H:%M:%S", timeinfo);
    return buffer;
}

void MolSaver::accumulateToFrom(MolAccumulator &acc, Atom *atom) const
{
    atom->setVisited();
    atom->eachNeighbour([this, &acc, atom](Atom *nbr) {
        if (!nbr->isVisited())
        {
            accumulateToFrom(acc, nbr);
        }

        acc.addBond(atom, nbr);
    });
}

}
